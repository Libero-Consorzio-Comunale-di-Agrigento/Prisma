package it.finmatica.protocollo.zk.utils

import groovy.transform.CompileStatic
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import org.zkoss.bind.BindContext
import org.zkoss.bind.Converter
import org.zkoss.bind.impl.BindContextImpl
import org.zkoss.zk.ui.Component

import java.util.Map.Entry

/**
 * @author sgirotti
 * http://books.zkoss.org/wiki/ZK_Developer%27s_Reference/MVVM/Data_Binding/Converter
 *<br>
 * <label value="@load(item.creationDate) @converter(vm.myConverter, format='yyyy/MM/dd')"/>
 *<br>
 <checkbox
 checked="@load(el.usoAttributi)
 @converter('it.finmatica.zk.converter.KeyToValue', S='true', defaultValue='false' )" disabled="true" />
 *
 */
@CompileStatic
public class KeyToValue implements Converter<Object, Object, Component> {

	public static final String DEFAULT_VALUE = 'defaultValue'
	Logger logger = LoggerFactory.getLogger(this.class);

    Map defParam = [
		'defaultValue':'',
	]

	public KeyToValue() {
		super();
	}

	@Override
	public Object coerceToBean(Object val, Component comp, BindContext ctx) {
		Map<Object, Object> attributes=ctx.getAttributes();
		logger.debug('attributes:{}',attributes);
		logger.debug('defParam:{}',defParam);
        Map effParam = [:]
		effParam.putAll(defParam);
		def _converter_args=attributes?.get(BindContextImpl.CONVERTER_ARGS)
		if (_converter_args && _converter_args instanceof Map) {
			Map convArgsMap = (Map) _converter_args;
			effParam.putAll(convArgsMap);
		}

        String valStr = val?.toString();
		if(val instanceof Number){
			valStr=val.intValue().toString();
		}

		logger.debug('effParam:{}',effParam);
        Entry<String, Object> foundConv=effParam.entrySet().find { Entry<String, Object> e ->
			def code = e.value;
            String codeStr = String.valueOf(code);
			if(code instanceof Number){
				codeStr=code.intValue().toString();
			}
			codeStr==valStr && e.key!=DEFAULT_VALUE
		}
		if(foundConv){
			foundConv.getKey()?:""
		}else{
			return val
		}
	}

	@Override
	public Object coerceToUi(Object val, Component comp, BindContext ctx) {
		Object defaultValue=ctx.getConverterArg(DEFAULT_VALUE)?:defParam.get(DEFAULT_VALUE);
		if (val == null)
			return defaultValue?:'';
        String valStr = val.toString();

		if(val instanceof Number){
			valStr=val.intValue().toString();
		}

        Object mapped=ctx.getConverterArg(valStr)?:defParam.get(valStr);
		if (mapped != null) {
			return mapped;
		}
		if (defaultValue != null) {
			return defaultValue;
		}
		return '';
	}
}
