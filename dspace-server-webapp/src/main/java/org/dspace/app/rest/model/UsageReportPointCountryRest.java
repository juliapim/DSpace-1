/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.model;

import org.dspace.statistics.util.LocationUtils;

/**
 * This class serves as a REST representation of a Country data Point of a {@link UsageReportRest} from the DSpace
 * statistics
 *
 * @author Maria Verdonck (Atmire) on 08/06/2020
 */
public class UsageReportPointCountryRest extends UsageReportPointRest {
    public static final String NAME = "country";

    private String label;
    public String getLabel() {
        return label;
    }

    public void setLabel(String label) {
        this.label = label;
        super.id = LocationUtils.getCountryCode(label);
    }

    @Override
    public void setId(String id) {
        super.id = id;
        this.label = LocationUtils.getCountryName(id);
    }

    @Override
    public String getType() {
        return NAME;
    }
}
