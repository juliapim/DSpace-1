/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.content.service;

import java.sql.SQLException;
import java.util.List;

import org.dspace.authorize.AuthorizeException;
import org.dspace.content.Item;
import org.dspace.content.Relationship;
import org.dspace.content.RelationshipType;
import org.dspace.core.Context;
import org.dspace.service.DSpaceCRUDService;

/**
 * This Service will use the DAO classes to access the information about Relationships from the database
 */
public interface RelationshipService extends DSpaceCRUDService<Relationship> {

    /**
     * Retrieves the list of Relationships currently in the system for which the given Item is either
     * a leftItem or a rightItem object
     * @param context   The relevant DSpace context
     * @param item      The Item that has to be the left or right item for the relationship to be included in the list
     * @return          The list of relationships for which each relationship adheres to the above listed constraint
     * @throws SQLException If something goes wrong
     */
    public List<Relationship> findByItem(Context context,Item item) throws SQLException;

    /**
     * Retrieves the full list of relationships currently in the system
     * @param context   The relevant DSpace context
     * @return  The list of all relationships currently in the system
     * @throws SQLException If something goes wrong
     */
    public List<Relationship> findAll(Context context) throws SQLException;

    /**
     * This method creates a relationship object in the database equal to the given relationship param
     * if this is a valid relationship
     * @param context       The relevant DSpace context
     * @param relationship  The relationship that will be created in the database if it is valid
     * @return              The created relationship with updated place variables
     * @throws SQLException         If something goes wrong
     * @throws AuthorizeException   If something goes wrong with authorizations
     */
    public Relationship create(Context context, Relationship relationship) throws SQLException, AuthorizeException;

    /**
     * Retrieves the highest integer value for the leftplace property of a Relationship for all relationships
     * that have the given item as a left item
     * @param context   The relevant DSpace context
     * @param item      The item that has to be the leftItem of a relationship for it to qualify
     * @return          The integer value of the highest left place property of all relationships
     *                  that have the given item as a leftitem property
     * @throws SQLException If something goes wrong
     */
    int findLeftPlaceByLeftItem(Context context, Item item) throws SQLException;

    /**
     * Retrieves the highest integer value for the rightplace property of a Relationship for all relationships
     * that have the given item as a right item
     * @param context   The relevant DSpace context
     * @param item      The item that has to be the rightitem of a relationship for it to qualify
     * @return          The integer value of the highest right place property of all relationships
     *                  that have the given item as a rightitem property
     * @throws SQLException If something goes wrong
     */
    int findRightPlaceByRightItem(Context context, Item item) throws SQLException;

    /**
     * This method will retrieve a list of Relationship objects by retrieving the list of Relationship objects
     * for the given item and then filtering the Relationship objects on the RelationshipType object that is
     * passed along to this method.
     * @param context           The relevant DSpace context
     * @param item              The Item for which the list of Relationship objects will be retrieved
     * @param relationshipType  The RelationshipType object on which the list of Relationship objects for the given
     *                          Item will be filtered
     * @return  The list of Relationship objects for the given Item filtered on the RelationshipType object
     * @throws SQLException If something goes wrong
     */
    public List<Relationship> findByItemAndRelationshipType(Context context, Item item,
                                                            RelationshipType relationshipType)
        throws SQLException;

    /**
     * This method will update the place for the Relationship and all other relationships found by the items and
     * relationship type of the given Relatonship. It will give this Relationship the last place in both the
     * left and right place determined by querying for the list of leftRelationships and rightRelationships
     * by the leftItem, rightItem and relationshipType of the given Relationship.
     * @param context           The relevant DSpace context
     * @param relationship      The Relationship object that will have it's place updated and that will be used
     *                          to retrieve the other relationships whose place might need to be updated
     * @param isCreation        Is the relationship new or did it already exist
     * @throws SQLException     If something goes wrong
     */
    public void updatePlaceInRelationship(Context context, Relationship relationship, boolean isCreation)
            throws SQLException, AuthorizeException;

    /**
     * This method will update the given item's metadata order.
     * If the relationships for the item have been modified and will calculate the place based on a
     * metadata field, this function will ensure the place is calculated.
     * @param context           The relevant DSpace context
     * @param relatedItem       The Item for which the list of Relationship location is calculated
     *                          based on a metadata field
     * @throws SQLException     If something goes wrong
     * @throws AuthorizeException
     *                          If the user is not authorized to update the item
     */
    public void updateItem(Context context, Item relatedItem) throws SQLException, AuthorizeException;

}