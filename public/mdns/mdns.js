var API_PREFIX = "/";

var dxClient = {
	
	domainListController: {},
	domains: [],
	selected: -1,
	
	initialise: function() {
		
		this.domainListController = new PDTable({ sticky : ['sidebar-title'], skeleton : 'sidebar-skeleton', table : $('domainlist'), rowTag : 'LI', 	cellTag : 'SPAN'});
		this.domainListController.clear();
		
		this.newDomainController.initialise();
		this.editDomainController.initialise();
		
		$('toolbar-add').observe('click', function(){
			this.editDomainController.kill();
			this.newDomainController.activate();
		}.bind(this));
						
		
		this.auth();
		
	},
	
	apiCall: function(f, args) {
		var p = API_PREFIX + f + ".json";
		// alert(p);
		args.onSuccess =  function(t) {
			r = t.responseJSON;
			args.onApiSuccess(r, t);
		}
		args.onFailure = function(t) {
			r = t.responseJSON;
			return this.apiCallFail(f, r);
		}
		return new Ajax.Request(p, args);
	},
	
	auth: function() {		
		$('loading').show();		
		this.apiCall('knox/gate', {
			'method': 'get',
			onApiSuccess: function(r, t) {
				
				if(!r.logged_in) {
					window.location = "/";
					return;
				}
				
				$('username').update(r.user.nickname);
				$('logout').href = r.auth_url;				
				$('loading').hide();
				
				this.loadAllDomains();
				
			}.bind(this)
		});
	},
	
	loadAllDomains: function() {
		$('loading').show();
		this.apiCall('rw/domains', {
			'method': 'get',
			onApiSuccess: function(r, t) {
				this.domains = r;
				this.refreshDomainList();
				$('loading').hide();
			}.bind(this)
		});
	},
	
	setSelection: function(s) {
		
		this.selected = s;
		
		$$('#domainlist li.selected').each(function(a){
			a.removeClassName('selected');
		});
		
		if(s != -1) {
			$('domain-' + s).addClassName('selected');
			this.newDomainController.kill();
			this.editDomainController.activate(this.domains[s]);
		}
		
	},
	
	refreshDomainCallback: function(e) {
		e.observe('click', function(){
			b = e.id.substring(e.id.indexOf('-') + 1);
			this.setSelection(b);
		}.bindAsEventListener(this));
	},
	
	refreshDomainList: function() {
		this.domainListController.clear();
		this.domainListController.addMulti(this.domains, {id: 'domain', callback: this.refreshDomainCallback.bind(this)});
		this.setSelection(this.selected);
	},
	
	apiCallFail: function(f, o) {	
			alert("API Call to "+ f + " failed.\n\nError:"+ o.err);		
			$('loading').hide();
	},
	
	editDomainController: {
		
		selectedDomain: {},
		selectedDomainRecords: {},
		
		initialise: function() {
			$('edit-domain-publish').observe('click', this.publish.bind(this));
			$('edit-domain-add-record').observe('click', this.addRecord.bind(this));
			$('edit-domain-record-edit-cancel').observe('click', this.cancelRecord.bind(this));
			$('edit-domain-record-edit-save').observe('click', this.saveRecord.bind(this));
			$('edit-domain-record-create-cancel').observe('click', this.cancelRecord.bind(this));
			$('edit-domain-record-create-save').observe('click', this.saveNewRecord.bind(this));
			
			$('edit-domain-record-edit-buttons').hide();
			$('edit-domain-record-create-buttons').hide();
			
			o = { sticky : ['edit-domain-records-title'], skeleton : 'edit-domain-records-skeleton', table : $('edit-domain-records-table'), rowTag : 'TR', 	cellTag : 'TD'};
			this.recordListController = new PDTable(o);
			this.recordListController.clear();
			
			$('edit-domain-record-edit-resource_type').observe('change', function(){
						this.resourceTypeSwitcher('edit-domain-record-edit');
					}.bind(this));
		},
		
		activate: function(d) {
			$('loading').show();
			
			dxClient.apiCall('rw/domains/' + d.id, {
				method: 'get',
				onApiSuccess: function(r, t) {
					
					this.selectedDomain = r;
					this.selectedDomainRecords = []; //r.records;
					this.selectedRecord = null;
					
					$('edit-domain-h1-name').update(this.selectedDomain.fqdn);
					$('edit-domain-detail-name').update(this.selectedDomain.fqdn);
					$('edit-domain-detail-version').update(this.selectedDomain.version);
					
					if(this.selectedDomain.active) {
						$('edit-domain-publish').show();
						$('edit-domain-detail-servers-group').show();		
						$('edit-domain-detail-warning').hide();				
					} else {
						$('edit-domain-publish').hide();
						$('edit-domain-detail-servers-group').hide();
						$('edit-domain-detail-warning').show();
					}
					
					this.refreshRecordList();
					
					$('loading').hide();
					$('edit-domain').show();
				}.bind(this)
			});
			
		},
		
		refreshRecordList: function() {
			this.recordListController.clear();
			this.recordListController.addMulti(this.selectedDomainRecords, {id: 'record', callback: this.refreshRecordCallback.bind(this)});
			// this.setSelection(this.selected);			
		},
		
		refreshRecordCallback: function(e) {
			f = e.getElementsByTagName('input');
			$A(f).each(function(a){
				if($(a).hasClassName('edit')) {
					$(a).observe('click', function() { 
						this.selectedRecord = this.selectedDomainRecords[PDTable.extractFragment(e.id)];
						this.editRecord();
					}.bind(this));
				}
				if($(a).hasClassName('delete')) {
					$(a).observe('click', function() { 
						this.deleteRecord(PDTable.extractFragment(e.id));
					}.bind(this));
				}
			}.bind(this));
		},
		
		kill: function() {
			dxClient.setSelection(-1);
			$('edit-domain').hide();	
		},
		
		publish: function() {
			$('loading').show();
			domain = this.selectedDomain;
			dxClient.apiCall('domain.publish',{
				method: 'post',
				parameters: {'id': domain.id},
				onApiSuccess: function(r, t) {
					domain.version = r.version;
					$('edit-domain-detail-version').update(this.selectedDomain.version);
					$('loading').hide();
				}.bind(this)
			});
			
		},

		cancelRecord: function() {	
			$('edit-domain-record-edit').hide();			
		},
		
		deleteRecord: function(id) {
			$('loading').show();
			toDelete = this.selectedDomainRecords[id];
			dxClient.apiCall('record.destroy',{
				method: 'post',
				parameters: {'id': toDelete.id},
				onApiSuccess: function(r, t) {
					$('loading').hide();
					this.selectedDomainRecords = this.selectedDomainRecords.without(toDelete);
					this.refreshRecordList();
				}.bind(this)
			});
		},
		
		editRecord: function() {
			r = this.selectedRecord;
			Object.keys(r).each(function(k){
				if($('edit-domain-record-edit-' + k)) {
					$('edit-domain-record-edit-' + k).value = r[k];
				}
			});
			this.resourceTypeSwitcher('edit-domain-record-edit');
			
			$('edit-domain-record-create-buttons').hide();
			$('edit-domain-record-edit-buttons').show();
			$('edit-domain-record-edit').show();
		},
		
		saveRecord: function() {
				r = this.selectedRecord;
				Object.keys(r).each(function(k){
					if($('edit-domain-record-edit-' + k)) {
						r[k] = $('edit-domain-record-edit-' + k).value;
					}
				});
								
				$('loading').show();

				dxClient.apiCall('record.modify', {
					method: 'post',
					parameters: this.selectedRecord,
					onApiSuccess: function(r, t) {
						$('loading').hide();
						this.refreshRecordList();			
						this.cancelRecord();
					}.bind(this)
				});				
		},
		
		addRecord: function() {
			$w('name priority weight port target').each(function(k){
				if($('edit-domain-record-edit-' + k)) {
					$('edit-domain-record-edit-' + k).value = "";
				}
			});
			$('edit-domain-record-edit-resource_type').value = "A";
			this.resourceTypeSwitcher('edit-domain-record-edit');
			
			$('edit-domain-record-create-buttons').show();
			$('edit-domain-record-edit-buttons').hide();
			$('edit-domain-record-edit').show();
		},
		
		saveNewRecord: function() {
			r = {'domain': this.selectedDomain.id}
			$w('name resource_type priority weight port target').each(function(k){
				if($('edit-domain-record-edit-' + k)) {
					r[k] = $('edit-domain-record-edit-' + k).value;
				}
			});

			$('loading').show();

			dxClient.apiCall('record.create', {
				method: 'post',
				parameters: r,
				onApiSuccess: function(r, t) {
					$('loading').hide();
					this.selectedDomainRecords.push(r.record);
					this.refreshRecordList();			
					this.cancelRecord();
				}.bind(this)
			});
			
		},
		
		resourceTypeSwitcher: function(prefix) {
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

	},
	
	newDomainController: {
		
		initialise: function() {
			$('new-domain-cancel').observe('click', this.cancel.bind(this));
			$('new-domain-create').observe('click', this.create.bind(this));
		},
		
		activate: function() {
			$('new-domain').show();
			$('new-domain-name').value = '';
		},
		
		kill: function() {
				$('new-domain').hide();			
		},
		
		create: function() {
			dom_to = $('new-domain-name').value;
			if(dom_to == "") {
				alert("Please enter the domain name first.");
				return;
			}
			
			this.kill();
			$('loading').show();
			
			dxClient.apiCall('domain.create', {
				method: 'post',
				parameters: {fqdn: dom_to},
				onApiSuccess: function(r, t) {
					
					$('loading').hide();
					dxClient.loadAllDomains();
					
				}.bind(this)
			});
			
		},
		
		cancel: function() {
			this.kill();
		}
		
	}
	
}

document.observe('dom:loaded', dxClient.initialise.bind(dxClient));
