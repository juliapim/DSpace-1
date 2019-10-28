/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest;

import static org.dspace.app.rest.utils.RegexUtils.REGEX_REQUESTMAPPING_IDENTIFIER_AS_UUID;

import java.io.IOException;
import java.sql.SQLException;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;

import com.fasterxml.jackson.databind.JsonNode;
import org.dspace.app.rest.model.ItemRest;
import org.dspace.app.rest.model.hateoas.ItemResource;
import org.dspace.app.rest.repository.CollectionRestRepository;
import org.dspace.app.rest.utils.ContextUtil;
import org.dspace.app.rest.utils.Utils;
import org.dspace.authorize.AuthorizeException;
import org.dspace.core.Context;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.rest.webmvc.ControllerUtils;
import org.springframework.hateoas.ResourceSupport;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/core/itemtemplates" + REGEX_REQUESTMAPPING_IDENTIFIER_AS_UUID + "/")
public class ItemtemplateRestController {

    @Autowired
    private Utils utils;

    @Autowired
    private CollectionRestRepository collectionRestRepository;

    @PreAuthorize("hasAuthority('AUTHENTICATED')")
    @RequestMapping(method = RequestMethod.GET)
    public ItemResource getTemplateItem(HttpServletRequest request, @PathVariable UUID uuid)
        throws SQLException {

        Context context = ContextUtil.obtainContext(request);
        ItemRest templateItem = collectionRestRepository.getTemplateItem(context, uuid);

        return new ItemResource(templateItem, utils);
    }

    @PreAuthorize("hasAuthority('AUTHENTICATED')")
    @RequestMapping(method = RequestMethod.PATCH)
    public ResponseEntity<ResourceSupport> replaceTemplateItem(HttpServletRequest request, @PathVariable UUID uuid,
                                                               @RequestBody(required = true) JsonNode jsonNode)
        throws SQLException, AuthorizeException {

        Context context = ContextUtil.obtainContext(request);
        ItemRest templateItem = collectionRestRepository.patchTemplateItem(context, uuid, jsonNode);

        return ControllerUtils.toResponseEntity(HttpStatus.OK, null,
            new ItemResource(templateItem, utils));
    }

    @PreAuthorize("hasAuthority('AUTHENTICATED')")
    @RequestMapping(method = RequestMethod.DELETE)
    public ResponseEntity<ResourceSupport> deleteTemplateItem(HttpServletRequest request, @PathVariable UUID uuid)
        throws SQLException, AuthorizeException, IOException {

        Context context = ContextUtil.obtainContext(request);
        collectionRestRepository.removeTemplateItem(context, uuid);

        return ControllerUtils.toEmptyResponse(HttpStatus.NO_CONTENT);
    }
}
