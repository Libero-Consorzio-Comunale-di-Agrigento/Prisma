/**
 *
 */
package it.finmatica.protocollo.zk.utils

import groovy.transform.CompileStatic

/**
 * @author agentilini
 *
 */
@CompileStatic
class ForCheckboxYN extends KeyToValue {

	ForCheckboxYN() {
		super()
		defParam.putAll([Y:true, N:false, defaultValue:false] as Map<? extends String, ?>)
	}
}
