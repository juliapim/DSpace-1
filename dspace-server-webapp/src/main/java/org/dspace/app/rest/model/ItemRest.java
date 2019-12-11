/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.model;

import java.util.Date;

import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * The Item REST Resource
 *
 * @author Andrea Bollini (andrea.bollini at 4science.it)
 */
@LinksRest(links = {
        @LinkRest(
                name = ItemRest.BUNDLES,
                linkClass = BundleRest.class,
                method = "getBundles",
                embedOptional = true
        ),
        @LinkRest(
                name = ItemRest.OWNING_COLLECTION,
                linkClass = CollectionRest.class,
                method = "getOwningCollection",
                embedOptional = true
        ),
        @LinkRest(
                name = ItemRest.RELATIONSHIPS,
                linkClass = RelationshipRest.class,
                method = "getRelationships",
                embedOptional = true
        ),
        @LinkRest(
                name = ItemRest.TEMPLATE_ITEM_OF,
                linkClass = CollectionRest.class,
                method = "getTemplateItemOf",
                embedOptional = true
        )
})
public class ItemRest extends DSpaceObjectRest {
    public static final String NAME = "item";
    public static final String PLURAL_NAME = "items";
    public static final String CATEGORY = RestAddressableModel.CORE;

    public static final String BUNDLES = "bundles";
    public static final String OWNING_COLLECTION = "owningCollection";
    public static final String RELATIONSHIPS = "relationships";
    public static final String TEMPLATE_ITEM_OF = "templateItemOf";

    private boolean inArchive = false;
    private boolean discoverable = false;
    private boolean withdrawn = false;
    private Date lastModified = new Date();

    @Override
    public String getCategory() {
        return CATEGORY;
    }

    @Override
    @JsonProperty(access = JsonProperty.Access.READ_ONLY)
    public String getType() {
        return NAME;
    }

    public boolean getInArchive() {
        return inArchive;
    }

    public void setInArchive(boolean inArchive) {
        this.inArchive = inArchive;
    }

    public boolean getDiscoverable() {
        return discoverable;
    }

    public void setDiscoverable(boolean discoverable) {
        this.discoverable = discoverable;
    }

    public boolean getWithdrawn() {
        return withdrawn;
    }

    public void setWithdrawn(boolean withdrawn) {
        this.withdrawn = withdrawn;
    }

    public Date getLastModified() {
        return lastModified;
    }

    public void setLastModified(Date lastModified) {
        this.lastModified = lastModified;
    }
}
