/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest;

import org.dspace.app.rest.builder.SiteBuilder;
import org.dspace.app.rest.matcher.SiteMatcher;
import org.dspace.app.rest.test.AbstractControllerIntegrationTest;
import org.dspace.content.Site;
import org.hamcrest.Matchers;
import org.junit.Test;

import static org.hamcrest.Matchers.is;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

public class SiteRestRepositoryIT extends AbstractControllerIntegrationTest {

    @Test
    public void findAll() throws Exception{


        context.turnOffAuthorisationSystem();
        //This will always return just one site, DSpace doesn't allow for more to be created
        Site site = SiteBuilder.createSite(context).build();



        getClient().perform(get("/api/core/sites"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$._embedded.sites[0]", SiteMatcher.matchEntry(site)))
                .andExpect(jsonPath("$._links.self.href", Matchers.containsString("/api/core/sites")))
                .andExpect(jsonPath("$.page.size", is(20)));

    }

    @Test
    public void findOne() throws Exception{


        context.turnOffAuthorisationSystem();
        //This will always return just one site, DSpace doesn't allow for more to be created
        Site site = SiteBuilder.createSite(context).build();



        getClient().perform(get("/api/core/sites/" + site.getID()))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$", SiteMatcher.matchEntry(site)))
                .andExpect(jsonPath("$._links.self.href", Matchers.containsString("/api/core/sites")));

    }
}
