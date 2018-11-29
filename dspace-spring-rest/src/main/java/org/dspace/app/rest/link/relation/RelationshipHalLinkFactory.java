package org.dspace.app.rest.link.relation;

import java.util.LinkedList;

import org.atteo.evo.inflector.English;
import org.dspace.app.rest.RestResourceController;
import org.dspace.app.rest.link.HalLinkFactory;
import org.dspace.app.rest.model.ItemRest;
import org.dspace.app.rest.model.hateoas.RelationshipResource;
import org.springframework.data.domain.Pageable;
import org.springframework.hateoas.Link;
import org.springframework.stereotype.Component;

@Component
public class RelationshipHalLinkFactory extends HalLinkFactory<RelationshipResource, RestResourceController> {
    protected void addLinks(RelationshipResource halResource, Pageable pageable, LinkedList<Link> list)
        throws Exception {

        list.add(buildLink("leftItem", getMethodOn()
            .findOne(ItemRest.CATEGORY, English.plural(ItemRest.NAME), halResource.getContent().getLeftId(), null)));

        list.add(buildLink("rightItem", getMethodOn()
            .findOne(ItemRest.CATEGORY, English.plural(ItemRest.NAME), halResource.getContent().getRightId(), null)));
    }

    protected Class<RestResourceController> getControllerClass() {
        return RestResourceController.class;
    }

    protected Class<RelationshipResource> getResourceClass() {
        return RelationshipResource.class;
    }
}
