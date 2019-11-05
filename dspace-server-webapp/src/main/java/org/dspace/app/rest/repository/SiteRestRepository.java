/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.repository;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import javax.servlet.http.HttpServletRequest;

import org.dspace.app.rest.model.SiteRest;
import org.dspace.app.rest.model.patch.Patch;
import org.dspace.app.rest.projection.Projection;
import org.dspace.app.rest.repository.patch.DSpaceObjectPatch;
import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Site;
import org.dspace.content.service.SiteService;
import org.dspace.core.Context;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.stereotype.Component;

/**
 * This is the repository responsible to manage Item Rest object
 *
 * @author Andrea Bollini (andrea.bollini at 4science.it)
 */

@Component(SiteRest.CATEGORY + "." + SiteRest.NAME)
public class SiteRestRepository extends DSpaceObjectRestRepository<Site, SiteRest> {

    private final SiteService sitesv;

    @Autowired
    public SiteRestRepository(SiteService dsoService) {
        super(dsoService, new DSpaceObjectPatch<SiteRest>() {});
        this.sitesv = dsoService;
    }

    @Override
    public SiteRest findOne(Context context, UUID id) {
        Site site = null;
        try {
            site = sitesv.find(context, id);
        } catch (SQLException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
        if (site == null) {
            return null;
        }
        return converter.toRest(site, utils.obtainProjection());
    }

    @Override
    public Page<SiteRest> findAll(Context context, Pageable pageable) {
        List<Site> sites = new ArrayList<Site>();
        int total = 1;
        try {
            sites.add(sitesv.findSite(context));
        } catch (SQLException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
        Projection projection = utils.obtainProjection(true);
        Page<SiteRest> page = new PageImpl<Site>(sites, pageable, total)
                .map((object) -> converter.toRest(object, projection));
        return page;
    }

    @Override
    @PreAuthorize("hasAuthority('ADMIN')")
    protected void patch(Context context, HttpServletRequest request, String apiCategory, String model, UUID id,
                         Patch patch) throws AuthorizeException, SQLException {
        patchDSpaceObject(apiCategory, model, id, patch);
    }

    @Override
    public Class<SiteRest> getDomainClass() {
        return SiteRest.class;
    }
}
