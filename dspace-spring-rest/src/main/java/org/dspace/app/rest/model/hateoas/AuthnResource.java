/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.model.hateoas;

import org.dspace.app.rest.model.AuthnRest;
import org.dspace.app.rest.utils.Utils;

/**
 * Authn Rest Resource, used to link to login, logout, status, ...
 *
 * @author Atmire NV (info at atmire dot com)
 */
@RelNameDSpaceResource(AuthnRest.NAME)
public class AuthnResource extends DSpaceResource<AuthnRest>{
    public AuthnResource(AuthnRest data, Utils utils, String... rels) {
        super(data, utils, rels);
    }
}
