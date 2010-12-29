/* PDTable, v1.1 (now works in IE!)
 * Copyright (c) 2006 Patrick Quinn-Graham
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 */

var PDTable = Class.create({
	initialize: function(options) {
		if(Object.isString(options.skeleton) || Object.isElement(options.skeleton)) {
			options.skeletons = [options.skeleton] ;
		}
		options.skeletons.each(function(a){
			$(a).style.display = 'none';
			options.sticky[options.sticky.length] = a;
		});
		this.options = {
			sticky : [],
			skeletons : [],
			defaultskeleton : 0,
			table : null,
			rowTag : 'TR',
			cellTag : 'TD'
		};
		Object.keys(options).each(function(k){
			this.options[k] = options[k];
		}.bind(this));
	},
	clear: function() {
		$A($(this.options.table).getElementsByTagName(this.options.rowTag)).each(function(a){
			test = 1;
			$A(this.options.sticky).each(function(b){ 
				if(a.id == b) {
					test = 0;
				}
			});
			if(test)
				$(a).remove();
		}.bind(this));
	},
	addRow: function(opts) {
		if(!opts) return false; /*Can't really do anything.*/
		if(!opts.skeleton)
			opts.skeleton = this.options.defaultskeleton;
		r = $(this.options.skeletons[opts.skeleton]).cloneNode(true);
		r.id = opts.id;
		r.style.display = '';
		if($(this.options.table).firstChild.nodeName == "TBODY") {
			out = $(this.options.table).firstChild;
		} else {
			out = $(this.options.table);
		}
		out.appendChild(r);
		$A(r.getElementsByTagName(this.options.cellTag)).each(function(td) {
			if(td.className.indexOf(' ') != -1) {
				className = td.className.substring(0, td.className.indexOf(' '));
			} else {
				className = td.className;
			}
			b = className.substring(className.indexOf('-') + 1);
			if(opts.values[b])
				td.firstChild.nodeValue = opts.values[b];
		});
		if(opts.callback) {
			opts.callback(r);
		}
		return r;
	},
	addMulti: function(values, opts) {
		if(!opts) return false;
		if(!Object.isArray(values)) return false;
		values.each(function(v, i){
			this.addRow({ id: opts.id + "-" + i, values: v, callback: opts.callback })
		}.bind(this));
	}
});

PDTable.extractFragment = function(f) {
	str = f.substring(f.indexOf('-') + 1);
	if(f.indexOf('-') >= 0) {
		str = PDTable.extractFragment(str);
	}
	return str;
}