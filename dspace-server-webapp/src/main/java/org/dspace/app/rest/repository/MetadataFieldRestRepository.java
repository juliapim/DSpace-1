/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.repository;

import static java.lang.Integer.parseInt;
import static org.apache.commons.lang3.StringUtils.isBlank;
import static org.dspace.app.rest.model.SearchConfigurationRest.Filter.OPERATOR_EQUALS;

import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;
import javax.servlet.http.HttpServletRequest;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.Logger;
import org.dspace.app.rest.Parameter;
import org.dspace.app.rest.SearchRestMethod;
import org.dspace.app.rest.exception.DSpaceBadRequestException;
import org.dspace.app.rest.exception.UnprocessableEntityException;
import org.dspace.app.rest.model.MetadataFieldRest;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.MetadataField;
import org.dspace.content.MetadataSchema;
import org.dspace.content.NonUniqueMetadataException;
import org.dspace.content.service.MetadataFieldService;
import org.dspace.content.service.MetadataSchemaService;
import org.dspace.core.Context;
import org.dspace.discovery.DiscoverQuery;
import org.dspace.discovery.DiscoverResult;
import org.dspace.discovery.IndexableObject;
import org.dspace.discovery.SearchService;
import org.dspace.discovery.SearchServiceException;
import org.dspace.discovery.indexobject.IndexableMetadataField;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.rest.webmvc.ResourceNotFoundException;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Component;

/**
 * This is the repository responsible to manage MetadataField Rest object
 *
 * @author Andrea Bollini (andrea.bollini at 4science.it)
 */
@Component(MetadataFieldRest.CATEGORY + "." + MetadataFieldRest.NAME)
public class MetadataFieldRestRepository extends DSpaceRestRepository<MetadataFieldRest, Integer> {
    /**
     * log4j logger
     */
    private static Logger log = org.apache.logging.log4j.LogManager.getLogger(MetadataFieldRestRepository.class);

    @Autowired
    MetadataFieldService metadataFieldService;

    @Autowired
    MetadataSchemaService metadataSchemaService;

    @Autowired
    private SearchService searchService;

    @Override
    @PreAuthorize("permitAll()")
    public MetadataFieldRest findOne(Context context, Integer id) {
        MetadataField metadataField = null;
        try {
            metadataField = metadataFieldService.find(context, id);
        } catch (SQLException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
        if (metadataField == null) {
            return null;
        }
        return converter.toRest(metadataField, utils.obtainProjection());
    }

    @Override
    public Page<MetadataFieldRest> findAll(Context context, Pageable pageable) {
        try {
            List<MetadataField> metadataFields = metadataFieldService.findAll(context);
            return converter.toRestPage(metadataFields, pageable, utils.obtainProjection());
        } catch (SQLException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    @SearchRestMethod(name = "bySchema")
    public Page<MetadataFieldRest> findBySchema(@Parameter(value = "schema", required = true) String schemaName,
                                                Pageable pageable) {
        try {
            Context context = obtainContext();
            MetadataSchema schema = metadataSchemaService.find(context, schemaName);
            if (schema == null) {
                return null;
            }
            List<MetadataField> metadataFields = metadataFieldService.findAllInSchema(context, schema);
            return converter.toRestPage(metadataFields, pageable, utils.obtainProjection());
        } catch (SQLException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    /**
     * Endpoint for the search in the {@link MetadataField} objects by various different params representing the
     * field name. Query being a partial
     *
     * @param schemaName    an exact match of the prefix of the metadata schema (e.g. "dc", "dcterms", "eperson")
     * @param elementName   an exact match of the field's element (e.g. "contributor", "title")
     * @param qualifierName an exact match of the field's qualifier (e.g. "author", "alternative"
     * @param query         part of the fully qualified field, should start with the start of the schema, element or
     *                      qualifier (e.g. "dc.ti", "contributor", "auth", "contributor.ot")
     * @param pageable      the pagination options
     * @return List of {@link MetadataFieldRest} objects representing all {@link MetadataField} objects that match
     * the given params
     */
    @SearchRestMethod(name = "byFieldName")
    public Page<MetadataFieldRest> findByFieldName(@Parameter(value = "schema", required = false) String schemaName,
        @Parameter(value = "element", required = false) String elementName,
        @Parameter(value = "qualifier", required = false) String qualifierName,
        @Parameter(value = "query", required = false) String query,
        Pageable pageable) throws SQLException {
        Context context = obtainContext();
        List<String> filterQueries = new ArrayList<>();
        if (StringUtils.isNotBlank(schemaName)) {
            filterQueries.add(searchService.toFilterQuery(context, "schema", OPERATOR_EQUALS, schemaName).getFilterQuery());
        }
        if (StringUtils.isNotBlank(elementName)) {
            filterQueries.add(searchService.toFilterQuery(context, "element", OPERATOR_EQUALS, elementName).getFilterQuery());
        }
        if (StringUtils.isNotBlank(qualifierName)) {
            filterQueries.add(searchService.toFilterQuery(context, "qualifier", OPERATOR_EQUALS, qualifierName).getFilterQuery());
        }
        if (StringUtils.isNotBlank(query)) {
            filterQueries.add(searchService.toFilterQuery(context, "fieldName", OPERATOR_EQUALS, query).getFilterQuery() + "*");
        }

        DiscoverResult searchResult = null;
        DiscoverQuery discoverQuery = new DiscoverQuery();
        discoverQuery.addFilterQueries(filterQueries.toArray(new String[filterQueries.size()]));

        try {
            searchResult = searchService.search(context, null, discoverQuery);
        } catch (SearchServiceException e) {
            log.error("Error while searching with Discovery", e);
            throw new IllegalArgumentException("Error while searching with Discovery: " + e.getMessage());
        }

        List<MetadataField> matchingMetadataFields = new ArrayList<>();
        for (IndexableObject object: searchResult.getIndexableObjects()) {
            if (object instanceof IndexableMetadataField) {
                matchingMetadataFields.add(((IndexableMetadataField) object).getIndexedObject());
            }
        }
        // Correct conversion
        return converter.toRestPage(matchingMetadataFields, pageable, utils.obtainProjection());
    }

    @Override
    public Class<MetadataFieldRest> getDomainClass() {
        return MetadataFieldRest.class;
    }

    @Override
    @PreAuthorize("hasAuthority('ADMIN')")
    protected MetadataFieldRest createAndReturn(Context context)
            throws AuthorizeException, SQLException {

        // parse request body
        MetadataFieldRest metadataFieldRest;
        try {
            metadataFieldRest = new ObjectMapper().readValue(
                    getRequestService().getCurrentRequest().getHttpServletRequest().getInputStream(),
                    MetadataFieldRest.class
            );
        } catch (IOException excIO) {
            throw new DSpaceBadRequestException("error parsing request body", excIO);
        }

        // validate fields
        String schemaId = getRequestService().getCurrentRequest().getHttpServletRequest().getParameter("schemaId");
        if (isBlank(schemaId)) {
            throw new UnprocessableEntityException("metadata schema ID cannot be blank");
        }

        MetadataSchema schema = metadataSchemaService.find(context, parseInt(schemaId));
        if (schema == null) {
            throw new UnprocessableEntityException("metadata schema with ID " + schemaId + " not found");
        }

        if (isBlank(metadataFieldRest.getElement())) {
            throw new UnprocessableEntityException("metadata element (in request body) cannot be blank");
        }

        // create
        MetadataField metadataField;
        try {
            metadataField = metadataFieldService.create(context, schema,
                    metadataFieldRest.getElement(), metadataFieldRest.getQualifier(), metadataFieldRest.getScopeNote());
            metadataFieldService.update(context, metadataField);
        } catch (NonUniqueMetadataException e) {
            throw new UnprocessableEntityException(
                    "metadata field "
                            + schema.getName() + "." + metadataFieldRest.getElement()
                            + (metadataFieldRest.getQualifier() != null ? "." + metadataFieldRest.getQualifier() : "")
                            + " already exists"
            );
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        // return
        return converter.toRest(metadataField, utils.obtainProjection());
    }

    @Override
    @PreAuthorize("hasAuthority('ADMIN')")
    protected void delete(Context context, Integer id) throws AuthorizeException {

        try {
            MetadataField metadataField = metadataFieldService.find(context, id);

            if (metadataField == null) {
                throw new ResourceNotFoundException("metadata field with id: " + id + " not found");
            }

            metadataFieldService.delete(context, metadataField);
        } catch (SQLException e) {
            throw new RuntimeException("error while trying to delete " + MetadataFieldRest.NAME + " with id: " + id, e);
        }
    }

    @Override
    @PreAuthorize("hasAuthority('ADMIN')")
    protected MetadataFieldRest put(Context context, HttpServletRequest request, String apiCategory, String model,
                                    Integer id, JsonNode jsonNode) throws SQLException, AuthorizeException {

        MetadataFieldRest metadataFieldRest = new Gson().fromJson(jsonNode.toString(), MetadataFieldRest.class);

        if (isBlank(metadataFieldRest.getElement())) {
            throw new UnprocessableEntityException("metadata element (in request body) cannot be blank");
        }

        if (!Objects.equals(id, metadataFieldRest.getId())) {
            throw new UnprocessableEntityException("ID in request body doesn't match path ID");
        }

        MetadataField metadataField = metadataFieldService.find(context, id);
        if (metadataField == null) {
            throw new ResourceNotFoundException("metadata field with id: " + id + " not found");
        }

        metadataField.setElement(metadataFieldRest.getElement());
        metadataField.setQualifier(metadataFieldRest.getQualifier());
        metadataField.setScopeNote(metadataFieldRest.getScopeNote());

        try {
            metadataFieldService.update(context, metadataField);
            context.commit();
        } catch (NonUniqueMetadataException e) {
            throw new UnprocessableEntityException("metadata field "
                    + metadataField.getMetadataSchema().getName() + "." + metadataFieldRest.getElement()
                    + (metadataFieldRest.getQualifier() != null ? "." + metadataFieldRest.getQualifier() : "")
                    + " already exists");
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        return converter.toRest(metadataField, utils.obtainProjection());
    }
}
