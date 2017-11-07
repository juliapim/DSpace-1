/**
 * The contents of this file are subject to the license and copyright
 * detailed in the LICENSE and NOTICE files at the root of the source
 * tree and available online at
 *
 * http://www.dspace.org/license/
 */
package org.dspace.submit.step;

import org.apache.log4j.Logger;
import org.dspace.content.InProgressSubmission;
import org.dspace.core.Context;
import org.dspace.services.model.Request;
import org.dspace.submit.AbstractProcessingStep;


public class AccessStep extends AbstractProcessingStep
{
    /** log4j logger */
    private static Logger log = Logger.getLogger(AccessStep.class);

	@Override
	public void doProcessing(Context context, Request req) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void doPostProcessing(Context context, Request obj) {
		// TODO Auto-generated method stub
		
	}

}
