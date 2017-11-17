/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.app.rest.model;

import java.util.Date;
import java.util.UUID;

import org.dspace.app.rest.RestResourceController;

/**
 * The Access Condition REST Resource. It is intent to be an human or REST
 * client understandable representation of the DSpace ResourcePolicy.
 * 
 * @author Luigi Andrea Pascarelli (luigiandrea.pascarelli at 4science.it)
 *
 */
public class ResourcePolicyRest extends BaseObjectRest<Integer> {

	public static final String NAME = "accessCondition";
	public static final String CATEGORY = DirectlyAddressableRestModel.AUTHORIZATION;

	private String name;
	
	private String rpType;
	
	private String description;
	
	private UUID groupUUID;
	
	private UUID epersonUUID;
	
	private String action;
	
	private Date startDate;
	
	private Date endDate;
	
	public UUID getGroupUUID() {
		return groupUUID;
	}

	public void setGroupUUID(UUID groupUuid) {
		this.groupUUID = groupUuid;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}

	
	@Override
	public String getType() {
		return NAME;
	}

	@Override
	public String getCategory() {		
		return CATEGORY;
	}

	@Override
	public Class getController() {		
		return RestResourceController.class;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getRpType() {
		return rpType;
	}

	public void setRpType(String rpType) {
		this.rpType = rpType;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public UUID getEpersonUUID() {
		return epersonUUID;
	}

	public void setEpersonUUID(UUID epersonUUID) {
		this.epersonUUID = epersonUUID;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}

	public Date getStartDate() {
		return startDate;
	}

	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}


}
