/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.repository.patch.factories.impl;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.List;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.commons.lang3.StringUtils;
import org.apache.logging.log4j.Logger;
import org.dspace.app.rest.exception.DSpaceBadRequestException;
import org.dspace.app.rest.exception.UnprocessableEntityException;
import org.dspace.app.rest.model.MetadataValueRest;
import org.dspace.app.rest.model.patch.CopyOperation;
import org.dspace.app.rest.model.patch.JsonValueEvaluator;
import org.dspace.app.rest.model.patch.MoveOperation;
import org.dspace.app.rest.model.patch.Operation;
import org.dspace.content.DSpaceObject;
import org.dspace.content.Item;
import org.dspace.content.MetadataField;
import org.dspace.content.MetadataValue;
import org.dspace.content.factory.ContentServiceFactory;
import org.dspace.content.service.DSpaceObjectService;
import org.dspace.content.service.MetadataFieldService;
import org.dspace.core.Context;
import org.springframework.stereotype.Component;

/**
 * Class for PATCH operations on Dspace Objects' metadata
 * Options (can be done on other dso than Item also):
 * - ADD metadata (with schema.identifier.qualifier) value of a dso (here: Item)
 * <code>
 * curl -X PATCH http://${dspace.url}/api/core/items/<:id-item> -H "
 * Content-Type: application/json" -d '[{ "op": "add", "path": "
 * /metadata/schema.identifier.qualifier(/0|-)}", "value": "metadataValue"]'
 * </code>
 * - REMOVE metadata
 * <code>
 * curl -X PATCH http://${dspace.url}/api/core/items/<:id-item> -H "
 * Content-Type: application/json" -d '[{ "op": "remove",
 * "path": "/metadata/schema.identifier.qualifier(/0|-)}"]'
 * </code>
 * - REPLACE metadata
 * <code>
 * curl -X PATCH http://${dspace.url}/api/core/items/<:id-item> -H "
 * Content-Type: application/json" -d '[{ "op": "replace", "path": "
 * /metadata/schema.identifier.qualifier}", "value": "metadataValue"]'
 * </code>
 * - ORDERING metadata
 * <code>
 * curl -X PATCH http://${dspace.url}/api/core/items/<:id-item> -H "
 * Content-Type: application/json" -d '[{ "op": "move",
 * "from": "/metadata/schema.identifier.qualifier/index"
 * "path": "/metadata/schema.identifier.qualifier/newIndex"}]'
 * </code>
 * - COPY metadata
 * <code>
 * curl -X PATCH http://${dspace.url}/api/core/items/<:id-item> -H "
 * Content-Type: application/json" -d '[{ "op": "copy",
 * "from": "/metadata/schema.identifier.qualifier/indexToCopyFrom"
 * "path": "/metadata/schema.identifier.qualifier/-"}]'
 * </code>
 *
 * @author Maria Verdonck (Atmire) on 30/10/2019
 */
@Component
public class DspaceObjectMetadataOperation<R extends DSpaceObject> extends PatchOperation<R> {
    private static final Logger log
            = org.apache.logging.log4j.LogManager.getLogger(DspaceObjectMetadataOperation.class);

    /**
     * Path in json body of patch that uses this operation
     */
    private static final String METADATA_PATH = "/metadata";

    private ObjectMapper objectMapper = new ObjectMapper();

    /**
     * Implements the patch operation for metadata operations.
     *
     * @param context   context we're performing patch in
     * @param dso       the dso.
     * @param operation the metadata patch operation.
     * @return the updated dso
     */
    @Override
    public R perform(Context context, R dso, Operation operation) {
        performPatchOperation(context, dso, operation);
        return dso;
    }

    /**
     * Gets all the info about the metadata we're patching from the operation and sends it to the
     * appropriate method to perform the actual patch
     *
     * @param context   Context we're performing patch in
     * @param dso       object we're performing metadata patch on
     * @param operation patch operation
     */
    private void performPatchOperation(Context context, DSpaceObject dso, Operation operation) {
        DSpaceObjectService dsoService = ContentServiceFactory.getInstance().getDSpaceObjectService(dso);
        String mdElement = this.extractMdFieldStringFromOperation(operation);

        try {
            MetadataFieldService metadataFieldService = ContentServiceFactory.getInstance().getMetadataFieldService();
            MetadataField metadataField = metadataFieldService.findByString(context, mdElement, '.');

            String[] partsOfPath = operation.getPath().split("/");
            // Index of md being patched
            String indexInPath = (partsOfPath.length > 3) ? partsOfPath[3] : null;

            switch (operation.getOp()) {
                case "add":
                    MetadataValueRest metadataValueToAdd = this.extractMetadataValueFromOperation(operation);
                    add(context, dso, dsoService, metadataField, metadataValueToAdd, indexInPath);
                    return;
                case "remove":
                    remove(context, dso, dsoService, metadataField, indexInPath);
                    return;
                case "replace":
                    MetadataValueRest metadataValueToReplace = this.extractMetadataValueFromOperation(operation);
                    // Property of md being altered
                    String propertyOfMd = this.extractPropertyOfMdFromPath(partsOfPath);
                    String newValueMdAttribute = this.extractNewValueOfMd(operation);
                    replace(context, dso, dsoService, metadataField, metadataValueToReplace, indexInPath, propertyOfMd,
                            newValueMdAttribute);
                    return;
                case "move":
                    String[] partsFromMove = ((MoveOperation) operation).getFrom().split("/");
                    String indexToMoveFrom = (partsFromMove.length > 3) ? partsFromMove[3] : null;
                    move(context, dso, dsoService, metadataField, indexInPath, indexToMoveFrom);
                    return;
                case "copy":
                    String[] partsFromCopy = ((CopyOperation) operation).getFrom().split("/");
                    String indexToCopyFrom = (partsFromCopy.length > 3) ? partsFromCopy[3] : null;
                    copy(context, dso, dsoService, metadataField, indexToCopyFrom);
                    return;
                default:
                    throw new DSpaceBadRequestException("This operation (" + operation.getOp() + ") is not supported.");
            }
        } catch (SQLException e) {
            throw new DSpaceBadRequestException("SQLException in DspaceObjectMetadataOperation.performPatchOperation" +
                    " trying to find corresponding MetadataField to schema.element.qualifier found in path of patch."
                    , e);
        }
    }

    /**
     * Extract metadataValue from Operation by parsing the json and mapping it to a MetadataValueRest
     * @param operation     Operation whose value is begin parsed
     * @return MetadataValueRest extracted from json in operation value
     */
    private MetadataValueRest extractMetadataValueFromOperation(Operation operation) {
        MetadataValueRest metadataValue = null;
        try {
            if (operation.getValue() != null) {
                if (operation.getValue() instanceof JsonValueEvaluator) {
                    JsonNode valueNode = ((JsonValueEvaluator) operation.getValue()).getValueNode();
                    if (valueNode.isArray()) {
                        metadataValue = objectMapper.treeToValue(valueNode.get(0), MetadataValueRest.class);
                    } else {
                        metadataValue = objectMapper.treeToValue(valueNode, MetadataValueRest.class);
                    }
                }
                if (operation.getValue() instanceof String) {
                    String valueString = (String) operation.getValue();
                    metadataValue = new MetadataValueRest();
                    metadataValue.setValue(valueString);
                }
            }
        } catch (IOException e) {
            throw new DSpaceBadRequestException("IOException in " +
                    "DspaceObjectMetadataOperation.extractMetadataValueFromOperation trying to map json from " +
                    "operation.value to MetadataValue class.", e);
        }
        if (metadataValue == null) {
            throw new DSpaceBadRequestException("Could not extract MetadataValue Object from Operation");
        }
        return metadataValue;
    }

    /**
     * Extracts which property of the metadata is being changed in the replace patch operation
     * @param partsOfPath   Parts of the path of the operation, separated with /
     * @return The property that is begin replaced of the metadata
     */
    private String extractPropertyOfMdFromPath(String[] partsOfPath) {
        return (partsOfPath.length > 4) ? partsOfPath[4] : null;
    }

    /**
     * Extracts the new value of the metadata from the operation for the replace patch operation
     * @param operation     The patch operation
     * @return The new value of the metadata being replaced in the patch operation
     */
    private String extractNewValueOfMd(Operation operation) {
        if (operation.getValue() != null && operation.getValue() instanceof String) {
            return (String) operation.getValue();
        }
        return null;
    }

    /**
     * Extracts the mdField String (schema.element.qualifier) from the operation and returns it
     *
     * @param operation The patch operation
     * @return The mdField (schema.element.qualifier) patch is being performed on
     */
    private String extractMdFieldStringFromOperation(Operation operation) {
        String mdElement = StringUtils.substringBetween(operation.getPath(), METADATA_PATH + "/", "/");
        if (mdElement == null) {
            mdElement = StringUtils.substringAfter(operation.getPath(), METADATA_PATH + "/");
            if (mdElement == null) {
                throw new DSpaceBadRequestException("No metadata field string found in path: " + operation.getPath());
            }
        }
        return mdElement;
    }

    /**
     * Adds metadata to the dso (appending if index is 0 or left out, prepending if -)
     *
     * @param context       context patch is being performed in
     * @param dso           dso being patched
     * @param dsoService    service doing the patch in db
     * @param metadataField md field being patched
     * @param metadataValue value of md element
     * @param index         determines whether we're prepending (-) or appending (0) md value
     */
    private void add(Context context, DSpaceObject dso, DSpaceObjectService dsoService, MetadataField metadataField,
                     MetadataValueRest metadataValue, String index) {
        this.checkMetadataFieldNotNull(metadataField);
        int indexInt = 0;
        if (index != null && index.equals("-")) {
            indexInt = -1;
        }
        try {
            dsoService.addAndShiftRightMetadata(context, dso, metadataField.getMetadataSchema().getName(),
                    metadataField.getElement(), metadataField.getQualifier(), metadataValue.getLanguage(),
                    metadataValue.getValue(), metadataValue.getAuthority(), metadataValue.getConfidence(), indexInt);
        } catch (SQLException e) {
            throw new DSpaceBadRequestException("SQLException in DspaceObjectMetadataOperation.add trying to add " +
                    "metadata to dso.", e);
        }
    }

    /**
     * Removes a metadata from the dso at a given index (or all of that type if no index was given)
     *
     * @param context       context patch is being performed in
     * @param dso           dso being patched
     * @param dsoService    service doing the patch in db
     * @param metadataField md field being patched
     * @param index         index at where we want to delete metadata
     */
    private void remove(Context context, DSpaceObject dso, DSpaceObjectService dsoService, MetadataField metadataField,
                        String index) {
        this.checkMetadataFieldNotNull(metadataField);
        if (index == null) {
            //remove all metadata of this type
            try {
                dsoService.clearMetadata(context, dso, metadataField.getMetadataSchema().getName(),
                        metadataField.getElement(), metadataField.getQualifier(), Item.ANY);
            } catch (SQLException e) {
                log.error("SQLException in DspaceObjectMetadataOperation.remove trying to " +
                        "remove metadata from dso.", e);
            }
        } else {
            //remove metadata at index
            List<MetadataValue> metadataValues = dsoService.getMetadata(dso,
                    metadataField.getMetadataSchema().getName(), metadataField.getElement(),
                    metadataField.getQualifier(), Item.ANY);
            try {
                int indexInt = Integer.parseInt(index);
                if (indexInt >= 0 && metadataValues.size() > indexInt
                        && metadataValues.get(indexInt) != null) {
                    //remove that metadata
                    dsoService.removeMetadataValues(context, dso,
                            Arrays.asList(metadataValues.get(indexInt)));
                } else {
                    throw new UnprocessableEntityException("UnprocessableEntityException - There is no metadata of " +
                            "this type at that index");
                }
            } catch (NumberFormatException e) {
                throw new IllegalArgumentException("This index (" + index + ") is not valid nr", e);
            } catch (ArrayIndexOutOfBoundsException e) {
                throw new UnprocessableEntityException("There is no metadata of this type at that index");
            } catch (SQLException e) {
                throw new DSpaceBadRequestException("SQLException in DspaceObjectMetadataOperation.remove trying to " +
                        "remove metadata from dso.", e);
            }
        }
    }

    /**
     * Replaces metadata in the dso; 4 cases:
     *      * - If we replace everything: clears all metadata
     *      * - If we replace for a single field: clearMetadata on the field & add the new ones
     *      * - A single existing metadata value:
     *      * Retrieve the metadatavalue object & make alterations directly on this object
     *      * - A single existing metadata property:
     *      * Retrieve the metadatavalue object & make alterations directly on this object
     * @param context           context patch is being performed in
     * @param dso               dso being patched
     * @param dsoService        service doing the patch in db
     * @param metadataField     possible md field being patched (if null all md gets cleared)
     * @param metadataValue     value of md element
     * @param index             possible index of md being replaced
     * @param propertyOfMd      possible property of md being replaced
     * @param valueMdProperty   possible new value of property of md being replaced
     */
    private void replace(Context context, DSpaceObject dso, DSpaceObjectService dsoService, MetadataField metadataField,
                         MetadataValueRest metadataValue, String index, String propertyOfMd, String valueMdProperty) {
        // replace entire set of metadata
        if (metadataField == null || metadataField.getMetadataSchema().getName() == null) {
            this.replaceAllMetadata(context, dso, dsoService);
            return;
        }

        // replace all metadata for existing key
        if (metadataField.getMetadataSchema().getName() != null && index == null) {
            this.replaceMetadataFieldMetadata(context, dso, dsoService, metadataField, metadataValue);
            return;
        }
        // replace single existing metadata value
        if (metadataField.getMetadataSchema().getName() != null && index != null && propertyOfMd == null) {
            this.replaceSingleMetadataValue(dso, dsoService, metadataField, metadataValue, index);
            return;
        }
        // replace single property of exiting metadata value
        if (metadataField.getMetadataSchema().getName() != null && index != null && propertyOfMd != null) {
            this.replaceSinglePropertyOfMdValue(dso, dsoService, metadataField, index, propertyOfMd, valueMdProperty);
            return;
        }
    }

    /**
     * Clears all metadata of dso
     * @param context           context patch is being performed in
     * @param dso               dso being patched
     * @param dsoService        service doing the patch in db
     */
    private void replaceAllMetadata(Context context, DSpaceObject dso, DSpaceObjectService dsoService) {
        try {
            dsoService.clearMetadata(context, dso, Item.ANY, Item.ANY, Item.ANY, Item.ANY);
        } catch (SQLException e) {
            throw new DSpaceBadRequestException("SQLException in DspaceObjectMetadataOperation.replace trying to " +
                    "remove and replace metadata from dso.", e);
        }
        return;
    }

    /**
     * Replaces all metadata for an existing single mdField with new value(s)
     * @param context           context patch is being performed in
     * @param dso               dso being patched
     * @param dsoService        service doing the patch in db
     * @param metadataField     md field being patched
     * @param metadataValue     value of md element
     */
    private void replaceMetadataFieldMetadata(Context context, DSpaceObject dso, DSpaceObjectService dsoService,
                                              MetadataField metadataField, MetadataValueRest metadataValue) {
        try {
            dsoService.clearMetadata(context, dso, metadataField.getMetadataSchema().getName(),
                    metadataField.getElement(), metadataField.getQualifier(), Item.ANY);
            this.add(context, dso, dsoService, metadataField, metadataValue, null);
        } catch (SQLException e) {
            throw new DSpaceBadRequestException("SQLException in DspaceObjectMetadataOperation.replace trying to " +
                    "remove and replace metadata from dso.", e);
        }
    }

    /**
     * Replaces metadata value of a single metadataValue object
     *      Retrieve the metadatavalue object & make alerations directly on this object
     * @param dso               dso being patched
     * @param dsoService        service doing the patch in db
     * @param metadataField     md field being patched
     * @param metadataValue     new value of md element
     * @param index             index of md being replaced
     */
    // replace single existing metadata value
    private void replaceSingleMetadataValue(DSpaceObject dso, DSpaceObjectService dsoService,
                                            MetadataField metadataField, MetadataValueRest metadataValue,
                                            String index) {
        try {
            List<MetadataValue> metadataValues = dsoService.getMetadata(dso,
                    metadataField.getMetadataSchema().getName(), metadataField.getElement(),
                    metadataField.getQualifier(), Item.ANY);
            int indexInt = Integer.parseInt(index);
            if (indexInt >= 0 && metadataValues.size() > indexInt
                    && metadataValues.get(indexInt) != null) {
                // Alter this existing md
                MetadataValue existingMdv = metadataValues.get(indexInt);
                existingMdv.setAuthority(metadataValue.getAuthority());
                existingMdv.setConfidence(metadataValue.getConfidence());
                existingMdv.setLanguage(metadataValue.getLanguage());
                existingMdv.setValue(metadataValue.getValue());
                dsoService.setMetadataModified(dso);
            } else {
                throw new UnprocessableEntityException("There is no metadata of this type at that index");
            }
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("This index (" + index + ") is not valid nr", e);
        }
    }

    /**
     * Replaces single property of a specific mdValue object
     * @param dso               dso being patched
     * @param dsoService        service doing the patch in db
     * @param metadataField     md field being patched
     * @param index             index of md being replaced
     * @param propertyOfMd      property of md being replaced
     * @param valueMdProperty   new value of property of md being replaced
     */
    private void replaceSinglePropertyOfMdValue(DSpaceObject dso, DSpaceObjectService dsoService,
                                                MetadataField metadataField,
                                                String index, String propertyOfMd, String valueMdProperty) {
        try {
            List<MetadataValue> metadataValues = dsoService.getMetadata(dso,
                    metadataField.getMetadataSchema().getName(), metadataField.getElement(),
                    metadataField.getQualifier(), Item.ANY);
            int indexInt = Integer.parseInt(index);
            if (indexInt >= 0 && metadataValues.size() > indexInt && metadataValues.get(indexInt) != null) {
                // Alter only asked propertyOfMd
                MetadataValue existingMdv = metadataValues.get(indexInt);
                if (propertyOfMd.equals("authority")) {
                    existingMdv.setAuthority(valueMdProperty);
                }
                if (propertyOfMd.equals("confidence")) {
                    existingMdv.setConfidence(Integer.valueOf(valueMdProperty));
                }
                if (propertyOfMd.equals("language")) {
                    existingMdv.setLanguage(valueMdProperty);
                }
                if (propertyOfMd.equals("value")) {
                    existingMdv.setValue(valueMdProperty);
                }
                dsoService.setMetadataModified(dso);
            } else {
                throw new UnprocessableEntityException("There is no metadata of this type at that index");
            }
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Not all numbers are valid numbers. " +
                    "(Index and confidence should be nr)", e);
        }
    }

    /**
     * Moves metadata of the dso from indexFrom to indexTo
     *
     * @param context       context patch is being performed in
     * @param dso           dso being patched
     * @param dsoService    service doing the patch in db
     * @param metadataField md field being patched
     * @param indexFrom     index we're moving metadata from
     * @param indexTo       index we're moving metadata to
     */
    private void move(Context context, DSpaceObject dso,
                      DSpaceObjectService dsoService, MetadataField metadataField, String indexFrom, String indexTo) {
        this.checkMetadataFieldNotNull(metadataField);
        try {
            dsoService.moveMetadata(context, dso, metadataField.getMetadataSchema().getName(),
                    metadataField.getElement(), metadataField.getQualifier(), Integer.parseInt(indexFrom),
                    Integer.parseInt(indexTo));
        } catch (SQLException e) {
            throw new DSpaceBadRequestException("SQLException in DspaceObjectMetadataOperation.move trying to move " +
                    "metadata in dso.", e);
        }
    }

    /**
     * Copies metadata of the dso from indexFrom to new index at end of md
     *
     * @param context         context patch is being performed in
     * @param dso             dso being patched
     * @param dsoService      service doing the patch in db
     * @param metadataField   md field being patched
     * @param indexToCopyFrom index we're copying metadata from
     */
    private void copy(Context context, DSpaceObject dso, DSpaceObjectService dsoService, MetadataField metadataField,
                      String indexToCopyFrom) {
        this.checkMetadataFieldNotNull(metadataField);
        List<MetadataValue> metadataValues = dsoService.getMetadata(dso, metadataField.getMetadataSchema().getName(),
                metadataField.getElement(), metadataField.getQualifier(), Item.ANY);
        try {
            int indexToCopyFromInt = Integer.parseInt(indexToCopyFrom);
            if (indexToCopyFromInt >= 0 && metadataValues.size() > indexToCopyFromInt
                    && metadataValues.get(indexToCopyFromInt) != null) {
                MetadataValue metadataValueToCopy = metadataValues.get(indexToCopyFromInt);
                MetadataValueRest metadataValueRestToCopy = this.convertMdValueToRest(metadataValueToCopy);
                // Add mdv to end of md list
                this.add(context, dso, dsoService, metadataField, metadataValueRestToCopy, "-");
            } else {
                throw new UnprocessableEntityException("There is no metadata of this type at that index");
            }
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("This index (" + indexToCopyFrom + ") is not valid nr", e);
        }
    }

    @Override
    public boolean supports(R objectToMatch, String path) {
        return ((path.startsWith(METADATA_PATH) || path.equals(METADATA_PATH))
                && objectToMatch instanceof DSpaceObject);
    }

    /**
     * Converts a metadataValue (database entity) to a REST equivalent of it
     * @param md    Original metadataValue
     * @return The REST equivalent
     */
    private MetadataValueRest convertMdValueToRest(MetadataValue md) {
        MetadataValueRest dto = new MetadataValueRest();
        dto.setAuthority(md.getAuthority());
        dto.setConfidence(md.getConfidence());
        dto.setLanguage(md.getLanguage());
        dto.setPlace(md.getPlace());
        dto.setValue(md.getValue());
        return dto;
    }

    private void checkMetadataFieldNotNull(MetadataField metadataField) {
        if (metadataField == null) {
            throw new DSpaceBadRequestException("There was no metadataField found in path of operation");
        }
    }
}
