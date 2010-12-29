function editRecord(r) {
	url = "/dnsconfig/api/record/get";
	params = {"id": r};

	new Ajax.Request(url, {
		method: 'get',
		parameters: params,
		onSuccess: function(transport) {
			r = transport.responseJSON.record;
			Object.keys(r).each(function(k){
				if($('editRecordForm-' + k)) {
					$('editRecordForm-' + k).value = r[k];
				}
			});
			resourceTypeSwitcher('editRecordForm');
			$('editRecordForm').show();
			$('editRecordForm').scrollTo();
		}
	});
}

function publishDomain(r) {
	url = "/dnsconfig/api/domain/publish";
	params = {"id": r};

	new Ajax.Request(url, {
		method: 'post',
		parameters: params,
		onSuccess: function(transport) {
			r = transport.responseJSON;
			if(r.status != "ok") {
				alert("Failed.");
				return;
			}
			$('version').update(r.version);
		}
	});
}

function resourceTypeSwitcher(prefix) {
	a = $(prefix + '-resource_type');
	$(prefix + '-priority-row').hide();
	$(prefix + '-weight-row').hide();
	$(prefix + '-port-row').hide();
	if(a.value == "MX" || a.value == "SRV") {
		$(prefix + '-priority-row').show();		
	}
	if(a.value == "SRV") {
		$(prefix + '-priority-row').show();
		$(prefix + '-weight-row').show();
		$(prefix + '-port-row').show();
	}
}

document.observe('dom:loaded', function(){
		a = $('recordForm-resource_type');
		if(a) {
			Event.observe(a, 'change', function(){ resourceTypeSwitcher('recordForm'); });
			resourceTypeSwitcher('recordForm');			
		}
		b = $('editRecordForm-resource_type');
		if(b) {
			Event.observe(b, 'change', function(){ resourceTypeSwitcher('editRecordForm'); });
			resourceTypeSwitcher('editRecordForm');			
		}		
	});