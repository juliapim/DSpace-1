/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.util.Map;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.dspace.app.rest.builder.CommunityBuilder;
import org.dspace.app.rest.test.AbstractControllerIntegrationTest;
import org.junit.Before;
import org.junit.Test;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockMultipartFile;
import org.springframework.test.web.servlet.MvcResult;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

public class CommunityRestControllerIT extends AbstractControllerIntegrationTest {

    private String adminAuthToken;
    private String bitstreamContent;
    private String secondBitstreamContent;
    private MockMultipartFile bitstreamFile;
    private MockMultipartFile secondBitstreamFile;
    private RequestPostProcessor putRequestPostProcessor;

    @Before
    public void createStructure() throws Exception {
        context.turnOffAuthorisationSystem();
        parentCommunity = CommunityBuilder.createCommunity(context)
                .withName("Parent Community")
                .build();
        adminAuthToken = getAuthToken(admin.getEmail(), password);
        bitstreamContent = "Hello, World!";
        bitstreamFile = new MockMultipartFile("file",
                "hello.txt", MediaType.TEXT_PLAIN_VALUE,
                bitstreamContent.getBytes());
        secondBitstreamContent = "A more elaborate Hello, World!";
        secondBitstreamFile = new MockMultipartFile("file",
                "elaborate_hello.txt", MediaType.TEXT_PLAIN_VALUE,
                secondBitstreamContent.getBytes());
        putRequestPostProcessor = new RequestPostProcessor() {
            @Override
            public MockHttpServletRequest postProcessRequest(MockHttpServletRequest request) {
                request.setMethod("PUT");
                return request;
            }
        };
    }

    @Test
    public void createLogoNotLoggedIn() throws Exception {
        getClient().perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                .file(bitstreamFile))
                .andExpect(status().isUnauthorized());
    }

    @Test
    public void createLogo() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        MvcResult mvcPostResult = getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(bitstreamFile))
                .andExpect(status().isCreated())
                .andReturn();

        String postContent = mvcPostResult.getResponse().getContentAsString();
        Map<String, Object> mapPostResult = mapper.readValue(postContent, Map.class);
        String postUuid = String.valueOf(mapPostResult.get("uuid"));
        assert (postUuid != null);

        MvcResult mvcGetResult = getClient().perform(get(getUrlTemplate(parentCommunity.getID().toString())))
                .andExpect(status().is2xxSuccessful())
                .andReturn();

        String getContent = mvcGetResult.getResponse().getContentAsString();
        Map<String, Object> mapGetResult = mapper.readValue(getContent, Map.class);
        String getUuid = String.valueOf(mapGetResult.get("uuid"));
        assert (postUuid.equals(getUuid));
    }

    @Test
    public void createLogoNoRights() throws Exception {
        String userToken = getAuthToken(eperson.getEmail(), password);
        getClient(userToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(bitstreamFile))
                .andExpect(status().isForbidden());
    }

    @Test
    public void createDuplicateLogo() throws Exception {
        getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(bitstreamFile))
                .andExpect(status().isCreated());

        getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(bitstreamFile))
                .andExpect(status().isUnprocessableEntity());
    }

    @Test
    public void createLogoForNonexisting() throws Exception {
        getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate("16a4b65b-3b3f-4ef5-8058-ef6f5a653ef9"))
                        .file(bitstreamFile))
                .andExpect(status().isNotFound());
    }

    @Test
    public void updateLogoNotLoggedIn() throws Exception {
        getClient().perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(secondBitstreamFile)
                        .with(putRequestPostProcessor))
                .andExpect(status().isUnauthorized());
    }

    @Test
    public void updateLogo() throws Exception {
        ObjectMapper mapper = new ObjectMapper();
        MvcResult mvcPostResult = getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(bitstreamFile))
                .andExpect(status().isCreated())
                .andReturn();
        String postContent = mvcPostResult.getResponse().getContentAsString();
        Map<String, Object> mapPostResult = mapper.readValue(postContent, Map.class);
        String postUuid = String.valueOf(mapPostResult.get("uuid"));
        assert (postUuid != null);
        assert (bitstreamContent.length() == Integer.parseInt(String.valueOf(mapPostResult.get("sizeBytes"))));

        MvcResult mvcPutResult = getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(secondBitstreamFile)
                        .with(putRequestPostProcessor))
                .andExpect(status().is2xxSuccessful())
                .andReturn();
        String putContent = mvcPutResult.getResponse().getContentAsString();
        Map<String, Object> mapPutResult = mapper.readValue(putContent, Map.class);
        String putUuid = String.valueOf(mapPutResult.get("uuid"));
        assert (putUuid != null);
        assert (!postUuid.equals(putUuid));
        assert (secondBitstreamContent.length() == Integer.parseInt(String.valueOf(mapPutResult.get("sizeBytes"))));

        MvcResult mvcGetResult = getClient().perform(get(getUrlTemplate(parentCommunity.getID().toString())))
                .andExpect(status().is2xxSuccessful())
                .andReturn();
        String getContent = mvcGetResult.getResponse().getContentAsString();
        Map<String, Object> mapGetResult = mapper.readValue(getContent, Map.class);
        String getUuid = String.valueOf(mapGetResult.get("uuid"));
        assert (putUuid.equals(getUuid));
        assert (secondBitstreamContent.length() == Integer.parseInt(String.valueOf(mapGetResult.get("sizeBytes"))));
    }

    @Test
    public void updateLogoNoRights() throws Exception {
        getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(bitstreamFile))
                .andExpect(status().isCreated());

        String userToken = getAuthToken(eperson.getEmail(), password);
        getClient(userToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                    .file(secondBitstreamFile)
                    .with(putRequestPostProcessor))
                .andExpect(status().isForbidden());
    }

    @Test
    public void updateMissingLogo() throws Exception {
        getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(secondBitstreamFile)
                        .with(putRequestPostProcessor))
                .andExpect(status().isUnprocessableEntity());
    }

    @Test
    public void updateLogoForNonexisting() throws Exception {
        getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate("16a4b65b-3b3f-4ef5-8058-ef6f5a653ef9"))
                        .file(secondBitstreamFile)
                        .with(putRequestPostProcessor))
                .andExpect(status().isNotFound());
    }

    @Test
    public void deleteLogoNotLoggedIn() throws Exception {
        getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(bitstreamFile))
                .andExpect(status().isCreated());

        getClient().perform(delete(getUrlTemplate(parentCommunity.getID().toString())))
                .andExpect(status().isUnauthorized());
    }

    @Test
    public void deleteLogo() throws Exception {
        getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(bitstreamFile))
                .andExpect(status().isCreated());

        getClient(adminAuthToken).perform(delete(getUrlTemplate(parentCommunity.getID().toString())))
                .andExpect(status().isNoContent());
    }

    @Test
    public void deleteLogoNoRights() throws Exception {
        getClient(adminAuthToken).perform(
                MockMvcRequestBuilders.fileUpload(getUrlTemplate(parentCommunity.getID().toString()))
                        .file(bitstreamFile))
                .andExpect(status().isCreated());

        String userToken = getAuthToken(eperson.getEmail(), password);
        getClient(userToken).perform(delete(getUrlTemplate(parentCommunity.getID().toString())))
                .andExpect(status().isForbidden());
    }

    @Test
    public void deleteMissingLogo() throws Exception {
        getClient(adminAuthToken).perform(delete(getUrlTemplate(parentCommunity.getID().toString())))
                .andExpect(status().isUnprocessableEntity());
    }

    @Test
    public void deleteLogoForNonexisting() throws Exception {
        getClient(adminAuthToken).perform(delete(getUrlTemplate("16a4b65b-3b3f-4ef5-8058-ef6f5a653ef9")))
                .andExpect(status().isNotFound());
    }

    private String getUrlTemplate(String uuid) {
        return "/api/core/communities/" + uuid + "/logo";
    }
}
