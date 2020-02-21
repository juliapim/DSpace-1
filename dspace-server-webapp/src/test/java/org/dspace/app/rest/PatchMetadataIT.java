/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.not;
import static org.hamcrest.CoreMatchers.startsWith;
import static org.junit.Assert.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.ArrayList;
import java.util.List;

import org.dspace.app.rest.builder.CollectionBuilder;
import org.dspace.app.rest.builder.CommunityBuilder;
import org.dspace.app.rest.builder.ItemBuilder;
import org.dspace.app.rest.builder.WorkspaceItemBuilder;
import org.dspace.app.rest.matcher.MetadataMatcher;
import org.dspace.app.rest.model.patch.MoveOperation;
import org.dspace.app.rest.model.patch.Operation;
import org.dspace.app.rest.test.AbstractEntityIntegrationTest;
import org.dspace.content.Collection;
import org.dspace.content.Community;
import org.dspace.content.Item;
import org.dspace.content.MetadataValue;
import org.dspace.content.RelationshipType;
import org.dspace.content.WorkspaceItem;
import org.dspace.content.service.EntityTypeService;
import org.dspace.content.service.ItemService;
import org.dspace.content.service.RelationshipTypeService;
import org.dspace.content.service.WorkspaceItemService;
import org.hamcrest.Matchers;
import org.junit.Before;
import org.junit.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MvcResult;

/**
 * Created by kristof on 20/02/2020
 */
public class PatchMetadataIT extends AbstractEntityIntegrationTest {

    @Autowired
    private RelationshipTypeService relationshipTypeService;

    @Autowired
    private EntityTypeService entityTypeService;

    @Autowired
    private ItemService itemService;

    @Autowired
    private WorkspaceItemService workspaceItemService;

    private Collection collection;
    private WorkspaceItem publicationItem;
    private Item personItem1;
    private Item personItem2;
    private RelationshipType publicationPersonRelationshipType;

    private List<String> authorsOriginalOrder;

    @Before
    @Override
    public void setUp() throws Exception {
        super.setUp();
        context.turnOffAuthorisationSystem();

        Community community = CommunityBuilder.createCommunity(context)
                .withName("Parent community")
                .build();
        collection = CollectionBuilder.createCollection(context, community)
                .withName("Collection")
                .build();

        context.restoreAuthSystemState();
    }

    /**
     * A method to create a workspace publication containing 5 authors: 3 regular authors and 2 related Person items.
     * The authors are added in a specific order:
     * - "Whyte, William": Regular author
     * - "Dahlen, Sarah": Related Person
     * - "Peterson, Karrie": Regular author
     * - "Perotti, Enrico": Regular author
     * - "Linton, Oliver": Related Person
     */
    private void initPersonPublicationWorkspace() throws Exception {
        // Setup the original order of authors
        authorsOriginalOrder = new ArrayList<>();
        authorsOriginalOrder.add("Whyte, William");
        // Second one will be virtual metadata
        authorsOriginalOrder.add("Dahlen, Sarah");
        authorsOriginalOrder.add("Peterson, Karrie");
        authorsOriginalOrder.add("Perotti, Enrico");
        // 5th one will be virtual metadata
        authorsOriginalOrder.add("Linton, Oliver");

        context.turnOffAuthorisationSystem();

        personItem1 = ItemBuilder.createItem(context, collection)
                .withTitle("Person 1")
                .withPersonIdentifierFirstName("Sarah")
                .withPersonIdentifierLastName("Dahlen")
                .withRelationshipType("Person")
                .build();
        personItem2 = ItemBuilder.createItem(context, collection)
                .withTitle("Person 2")
                .withPersonIdentifierFirstName("Oliver")
                .withPersonIdentifierLastName("Linton")
                .withRelationshipType("Person")
                .build();
        publicationItem = WorkspaceItemBuilder.createWorkspaceItem(context, collection)
                .withTitle("Publication 1")
                .withRelationshipType("Publication")
                .build();
        publicationPersonRelationshipType = relationshipTypeService.findbyTypesAndTypeName(context,
                entityTypeService.findByEntityType(context, "Publication"),
                entityTypeService.findByEntityType(context, "Person"),
                "isAuthorOfPublication",
                "isPublicationOfAuthor");

        String adminToken = getAuthToken(admin.getEmail(), password);

        // Make sure we grab the latest instance of the Item from the database before adding a regular author
        WorkspaceItem publication = workspaceItemService.find(context, publicationItem.getID());
        itemService.addMetadata(context, publication.getItem(),
                "dc", "contributor", "author", Item.ANY, authorsOriginalOrder.get(0));
        workspaceItemService.update(context, publication);

        context.restoreAuthSystemState();

        // Create a relationship between publication and person 1
        MvcResult mvcResult = getClient(adminToken).perform(post("/api/core/relationships")
                .param("relationshipType", publicationPersonRelationshipType.getID().toString())
                .contentType(MediaType.parseMediaType
                        (org.springframework.data.rest.webmvc.RestMediaTypes.TEXT_URI_LIST_VALUE))
                .content("https://localhost:8080/server/api/core/items/" + publicationItem.getItem().getID() + "\n" +
                                "https://localhost:8080/server/api/core/items/" + personItem1.getID()))
                .andExpect(status().isCreated())
                .andReturn();

        context.turnOffAuthorisationSystem();

        // Add two more regular authors
        List<String> regularMetadata = new ArrayList<>();
        publication = workspaceItemService.find(context, publicationItem.getID());
        regularMetadata.add(authorsOriginalOrder.get(2));
        regularMetadata.add(authorsOriginalOrder.get(3));
        itemService.addMetadata(context, publication.getItem(),
                "dc", "contributor", "author", null, regularMetadata);
        workspaceItemService.update(context, publication);

        context.restoreAuthSystemState();

        // Create a relationship between publication and person 2
        mvcResult = getClient(adminToken).perform(post("/api/core/relationships")
                .param("relationshipType", publicationPersonRelationshipType.getID().toString())
                .contentType(MediaType.parseMediaType
                        (org.springframework.data.rest.webmvc.RestMediaTypes.TEXT_URI_LIST_VALUE))
                .content("https://localhost:8080/server/api/core/items/" + publicationItem.getItem().getID() + "\n" +
                                "https://localhost:8080/server/api/core/items/" + personItem2.getID()))
                .andExpect(status().isCreated())
                .andReturn();

        publication = workspaceItemService.find(context, publicationItem.getID());
        List<MetadataValue> publicationAuthorList =
                itemService.getMetadata(publication.getItem(), "dc", "contributor", "author", Item.ANY);
        assertThat(publicationAuthorList.size(), equalTo(5));
        assertThat(publicationAuthorList.get(0).getValue(), equalTo(authorsOriginalOrder.get(0)));
        assertThat(publicationAuthorList.get(0).getAuthority(), not(startsWith("virtual::")));
        assertThat(publicationAuthorList.get(1).getValue(), equalTo(authorsOriginalOrder.get(1)));
        assertThat(publicationAuthorList.get(1).getAuthority(), startsWith("virtual::"));
        assertThat(publicationAuthorList.get(2).getValue(), equalTo(authorsOriginalOrder.get(2)));
        assertThat(publicationAuthorList.get(2).getAuthority(), not(startsWith("virtual::")));
        assertThat(publicationAuthorList.get(3).getValue(), equalTo(authorsOriginalOrder.get(3)));
        assertThat(publicationAuthorList.get(3).getAuthority(), not(startsWith("virtual::")));
        assertThat(publicationAuthorList.get(4).getValue(), equalTo(authorsOriginalOrder.get(4)));
        assertThat(publicationAuthorList.get(4).getAuthority(), startsWith("virtual::"));
    }

    /**
     * This test will move an author (dc.description.author) within a workspace publication's "traditionalpageone"
     * section from position 1 to 0 using a PATCH request and verify the order of the authors within the section.
     * Original Order: 0,1,2,3,4
     * Expected Order: 1,0,2,3,4
     */
    @Test
    public void moveTraditionalPageOneAuthorOneToZeroTest() throws Exception {
        initPersonPublicationWorkspace();

        List<String> expectedOrder = new ArrayList<>();
        expectedOrder.add(authorsOriginalOrder.get(1));
        expectedOrder.add(authorsOriginalOrder.get(0));
        expectedOrder.add(authorsOriginalOrder.get(2));
        expectedOrder.add(authorsOriginalOrder.get(3));
        expectedOrder.add(authorsOriginalOrder.get(4));

        moveTraditionalPageOneAuthorTest(1, 0, expectedOrder);
    }

    /**
     * This test will move an author (dc.description.author) within a workspace publication's "traditionalpageone"
     * section from position 2 to 0 using a PATCH request and verify the order of the authors within the section.
     * Original Order: 0,1,2,3,4
     * Expected Order: 2,0,1,3,4
     */
    @Test
    public void moveTraditionalPageOneAuthorTwoToZeroTest() throws Exception {
        initPersonPublicationWorkspace();

        List<String> expectedOrder = new ArrayList<>();
        expectedOrder.add(authorsOriginalOrder.get(2));
        expectedOrder.add(authorsOriginalOrder.get(0));
        expectedOrder.add(authorsOriginalOrder.get(1));
        expectedOrder.add(authorsOriginalOrder.get(3));
        expectedOrder.add(authorsOriginalOrder.get(4));

        moveTraditionalPageOneAuthorTest(2, 0, expectedOrder);
    }

    /**
     * This test will move an author (dc.description.author) within a workspace publication's "traditionalpageone"
     * section from position 3 to 0 using a PATCH request and verify the order of the authors within the section.
     * Original Order: 0,1,2,3,4
     * Expected Order: 3,0,1,2,4
     */
    @Test
    public void moveTraditionalPageOneAuthorThreeToZeroTest() throws Exception {
        initPersonPublicationWorkspace();

        List<String> expectedOrder = new ArrayList<>();
        expectedOrder.add(authorsOriginalOrder.get(3));
        expectedOrder.add(authorsOriginalOrder.get(0));
        expectedOrder.add(authorsOriginalOrder.get(1));
        expectedOrder.add(authorsOriginalOrder.get(2));
        expectedOrder.add(authorsOriginalOrder.get(4));

        moveTraditionalPageOneAuthorTest(3, 0, expectedOrder);
    }

    /**
     * This test will move an author (dc.description.author) within a workspace publication's "traditionalpageone"
     * section from position 4 to 0 using a PATCH request and verify the order of the authors within the section.
     * Original Order: 0,1,2,3,4
     * Expected Order: 4,0,1,2,3
     */
    @Test
    public void moveTraditionalPageOneAuthorFourToZeroTest() throws Exception {
        initPersonPublicationWorkspace();

        List<String> expectedOrder = new ArrayList<>();
        expectedOrder.add(authorsOriginalOrder.get(4));
        expectedOrder.add(authorsOriginalOrder.get(0));
        expectedOrder.add(authorsOriginalOrder.get(1));
        expectedOrder.add(authorsOriginalOrder.get(2));
        expectedOrder.add(authorsOriginalOrder.get(3));

        moveTraditionalPageOneAuthorTest(4, 0, expectedOrder);
    }

    /**
     * This test will move an author (dc.description.author) within a workspace publication's "traditionalpageone"
     * section from position 1 to 3 using a PATCH request and verify the order of the authors within the section.
     * Original Order: 0,1,2,3,4
     * Expected Order: 0,2,3,1,4
     */
    @Test
    public void moveTraditionalPageOneAuthorOneToThreeTest() throws Exception {
        initPersonPublicationWorkspace();

        List<String> expectedOrder = new ArrayList<>();
        expectedOrder.add(authorsOriginalOrder.get(0));
        expectedOrder.add(authorsOriginalOrder.get(2));
        expectedOrder.add(authorsOriginalOrder.get(3));
        expectedOrder.add(authorsOriginalOrder.get(1));
        expectedOrder.add(authorsOriginalOrder.get(4));

        moveTraditionalPageOneAuthorTest(1, 3, expectedOrder);
    }

    /**
     * This test will move an author (dc.description.author) within a workspace publication's "traditionalpageone"
     * section from position 1 to 4 using a PATCH request and verify the order of the authors within the section.
     * Original Order: 0,1,2,3,4
     * Expected Order: 0,2,3,4,1
     */
    @Test
    public void moveTraditionalPageOneAuthorOneToFourTest() throws Exception {
        initPersonPublicationWorkspace();

        List<String> expectedOrder = new ArrayList<>();
        expectedOrder.add(authorsOriginalOrder.get(0));
        expectedOrder.add(authorsOriginalOrder.get(2));
        expectedOrder.add(authorsOriginalOrder.get(3));
        expectedOrder.add(authorsOriginalOrder.get(4));
        expectedOrder.add(authorsOriginalOrder.get(1));

        moveTraditionalPageOneAuthorTest(1, 4, expectedOrder);
    }

    /**
     * This method moves an author (dc.description.author) within a workspace publication's "traditionalpageone"
     * section from position "from" to "path" using a PATCH request and verifies the order of the authors within the
     * section using an ordered list of expected author names.
     * @param from              The "from" index to use for the Move operation
     * @param path              The "path" index to use for the Move operation
     * @param expectedOrder     A list of author names sorted in the expected order
     */
    private void moveTraditionalPageOneAuthorTest(int from, int path, List<String> expectedOrder) throws Exception {
        List<Operation> ops = new ArrayList<Operation>();
        MoveOperation moveOperation = getTraditionalPageOneMoveAuthorOperation(from, path);
        ops.add(moveOperation);
        String patchBody = getPatchContent(ops);

        String token = getAuthToken(admin.getEmail(), password);

        getClient(token).perform(patch("/api/submission/workspaceitems/" + publicationItem.getID())
                .content(patchBody)
                .contentType(javax.ws.rs.core.MediaType.APPLICATION_JSON_PATCH_JSON))
                .andExpect(status().isOk());

        String authorField = "dc.contributor.author";
        getClient().perform(get("/api/submission/workspaceitems/" + publicationItem.getID()))
                .andExpect(status().isOk())
                .andExpect(content().contentType(contentType))
                .andExpect(jsonPath("$.sections.traditionalpageone", Matchers.allOf(
                        Matchers.is(MetadataMatcher.matchMetadata(authorField, expectedOrder.get(0), 0)),
                        Matchers.is(MetadataMatcher.matchMetadata(authorField, expectedOrder.get(1), 1)),
                        Matchers.is(MetadataMatcher.matchMetadata(authorField, expectedOrder.get(2), 2)),
                        Matchers.is(MetadataMatcher.matchMetadata(authorField, expectedOrder.get(3), 3)),
                        Matchers.is(MetadataMatcher.matchMetadata(authorField, expectedOrder.get(4), 4))
                )));
    }

    /**
     * Create a move operation on a workspace item's "traditionalpageone" section for
     * metadata field "dc.contributor.author".
     * @param from  The "from" index to use for the Move operation
     * @param path  The "path" index to use for the Move operation
     */
    private MoveOperation getTraditionalPageOneMoveAuthorOperation(int from, int path) {
        return new MoveOperation("/sections/traditionalpageone/dc.contributor.author/" + path,
                "/sections/traditionalpageone/dc.contributor.author/" + from);
    }

}
