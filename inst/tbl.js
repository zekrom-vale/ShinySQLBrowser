/*eslint-env jquery*/
/*global console, setTimeout, port, crudport, build, buildWhere*/
"use strict";


// l={a:{b:{c:{d:{e:1}}}}}
// evalName("l.a.b.c.d.e")
function evalName(name=undefined, sep="."){
	if(name===undefined)return UITable
	var list=name.split(sep);
	// if(!/\w+/i.test(root)) throw new Error(`Not Safe ${root}`)
	// var v=eval(list.shift())[list.shift()];
	list.shift();
	var v=UITable[list.shift()];
	while(list.length>0){
		if(v===undefined){
			console.error(`Can't find "${name}", gave up at:"${list.join(sep)}"`);
			return undefined;
		}
		v=v[list.shift()];
	}
	if(v===undefined)console.warn(`Can't find "${name}"`);
	return v;
}

function escapeHTML(unsafe) {
	return String(unsafe).replace(/[&<"'>]/g, m=>{
		switch(m){
			case '&':
				return '&amp;';
			case '<':
				return '&lt;';
			case '>':
				return '&gt;';
			case '"':
				return '&quot;';
			case "'":
				return '&#039;';
		}
	});
}

function write(tbl, el, val){
		el.data("val", val);
		render(tbl, el, val);
}

function applyTypeFun(typefun, col, type, val){
	if(typefun[col] !== undefined) return typefun[col](val)
	if(typefun[type] !== undefined) return typefun[type](val)
	typefun = evalName()
	if(typefun[type] !== undefined) return typefun[type](val)
	return val
}

function render(tbl, el, val=undefined){
	if(val===null)el.append("<div></div>");
	else{
		if(val===undefined)val=el.data("val");
		else el.data("val", val);
		let head=$(`#${el.data("col")}`);
		let col=head.data("col");
		let type=head.data("type");
		let typefun=evalName(tbl.find("table").data("js"));
		let txt = applyTypeFun(typefun, col, type, val)
		el.append($(`<div>${escapeHTML(txt)}</div>`));
	}
}

function busyadd(el){
		el.data("busy", (el.data("busy")||0)+1);
		//el.addClass("busy")
		setTimeout(()=>busysub(el), 100);
}
function busysub(el){
		el.data("busy", (el.data("busy")||0)-1);
		//el.removeClass("busy")
}
function isbusy(el){
		return el.data("busy")>0;
		//return el.hasClass("busy")
}
function read(el){
		return el.data("val");
}

function update(tbl, tr, data="data-val"){
	if(data==="null"){
		tr.find("td:not(.ecl)").each(function(){
			let td=$(this);
			td.empty();
			write(tbl, td, null);
		});
	}
	else if(data==="val"){
		tr.find("td:not(.ecl)").each(function(){
			let td=$(this);
			let val=td.find("*:first").val();
			td.empty();
			write(tbl, td, val);
		});
	}
	else if(data==="data-val"){
		tr.find("td:not(.ecl)").each(function(){
			let td=$(this);
			let val=td.data("val");
			td.empty();
			write(tbl, td, val);
		});
	}
	else{
		tr.find("td:not(.ecl)").each(function(){
			let td=$(this);
			let col=tbl.find("#"+td.data("col")).data("col");
			if(data[col]!==undefined){
				write(tbl, td, data[col][0]===undefined ? data[col] : data[col][0]);
			}
		});
	}
}

function resolve(tr, clas="bg-success"){
		tr.addClass(clas);
		setTimeout(function(){
			tr.removeClass(clas);
		}, 5000);
}

function dispError(tr, message){
	let el=$(`<tr class="bg-danger error msg"><td colspan="9999">${message}</tr></td>`);
	el.addClass("bg-danger");
	el.insertBefore(tr);
	//setTimeout(()=>el.remove(), 5000);
}

function clearError(tr){
	tr.removeClass("bg-danger");
	tr=tr.prev();
	while(tr.is(".error.msg")){
		let el=tr;
		tr=tr.prev();
		el.remove();
	}
}

async function commit(tbl, tr, port=undefined, commitout=true){
	//build(tr)
	if(port !== undefined){
		let data=build(tr);
		let where = buildWhere(data, tbl);
		
		var message;
		if(tr.hasClass("new-tr")){
			message=await port.create(data);
			
			if(message.status=="reject"){
				console.error(message.effect.error, message.effect.sql, message);
				dispError(tr, message.effect.error);
				return;
			}
			//Update tr with message.data values
			tr.find("td:not(.ecl)").each(function(){
				$(this).empty();
			});
			update(tbl, tr, message.data);
			tr.removeClass("new-tr");
			addRow(tbl, port, commitout);
		}
		else{
			message=await port.update(where, data);
			update(tbl, tr, "val");
		}
		if(message.status=="reject"){
			//error
			console.error(message.effect.error, message.effect.sql, message);
			dispError(tr, message.effect.error);
			return;
		}
	}
	
	//Remove active
	tr.removeClass("active");
	clearError(tr);
	resolve(tr);
}

// Creates an interactive row
// @param tbl The table to modify as a jQuery element
// @param tr The row to make interactive
// @param evnt The html event object
function create(tbl, tr, evnt, port=undefined, commitout=true){
	let target=$(evnt.target);
	if(!target.is("td"))target=target.parent();
	tr=$(tr);
	//Only if it isnt active
	if(!tr.hasClass("active")){
		tbl.find("tbody tr.active").each(function(){
			commit(tbl, $(this), port, commitout);
		});
		tr.addClass("active");
		//Find each cell in the row
		tr.find("td:not(.ecl)").each(function(){
			let td=$(this);
			//Copy the existing text
			let val=read(td);
			//Empty the cell
			td.empty();
			//Replace with the input in the header
			let input=tbl.find(`#${td.data("col")} template`).contents().clone();
			//Set value as saved text
			input.val(val);
			//Apend that node
			td.append(input);
		});
		//Focus on the clicked element
		while(target.length!=0 && target.find("*:first").prop('disabled')==true){
			target=target.next();
		}
		target.find("*:first").focus();
	}
	else busyadd(tr);
}

async function discard(tbl, tr, port){
	if(!tr.hasClass("new-tr")){
		let data=build(tr, true);
		let where = buildWhere(data, tbl);
		let message=await port.read(where);
		
		if(message.status=="reject"){
			console.error(message.effect.error, message.effect.sql, message);
			dispError(tr, message.effect.error);
			return;
		}
		//Find each cell in the row and empty it
		tr.find("td:not(.ecl)").each(function(){
			$(this).empty();
		});
		//Update tr with message.data values
		update(tbl, tr, message.data);
	}
	else{
		tr.find("td:not(.ecl)").each(function(){
			$(this).empty();
		});
	}
	//Remove active
	tr.removeClass("active");
	clearError(tr);
	resolve(tr, "bg-warning");
}


function main(tbl, id, commitout=true){
	//Add new port
	var port=new crudport(id);
	console.log(`Added port ${id}: `, port);
	tbl.find("td:not(.ecl)").each(function(){render(tbl, $(this))});
	
	mainrow(tbl, port, tbl.find("tr"), commitout);
	addRow(tbl, port, commitout);
}

function mainrow(tbl, port, tr, commitout=true){
	//On click add an input box
	tr.on("click", function(e){
		if(!($(e.target).is(".btn") || $(e.target).parents(".btn").is(".btn")))create(tbl, this, e, port, commitout)
	});
	
	//Deal with the click and hold
	tr.on("focusin", function(evnt){
		busyadd($(this));
	});
	
	tr.find("button.commit").on("click", function(evnt){
		commit(tbl, $(this).parents("tr"), port, commitout);
	});
	tr.find("button.discard").on("click", async function(evnt){
		discard(tbl, $(this).parents("tr"), port);
	});
	
	tr.find("button.remove").on("click", async function(evnt){
		var tr=$(this).parents("tr");
		async function conf(tr){
			let data=build(tr, true);
			let where = buildWhere(data, tbl);
			let message=await port.remove(where);if(message.status=="reject"){
				console.error(message.effect.error, message.effect.sql, message);
				dispError(tr, message.effect.error);
				return;
			}
			tr.remove()
		}
		
		if(evnt.shiftkey&&evnt.ctrlkey)return conf(tr)
		
		$.confirm({
			title: "Delete This Record?",
			contents: "This will delete the current record.<br>This cannot be undone!",
			type: 'red',
			animation: 'RotateXR',
			closeAnimation: 'RotateXR',
			buttons:{
				confirm: {
					action: ()=>conf(tr),
					btnClass: 'btn-red',
					keys: ["enter"]
				},
				cancel: {
					keys: ["esc"]
				}
			}
		})
	});
	//On click off destroy the inputs
	if(commitout)tr.on("focusout", function(evnt){
		let tr=$(this);
		setTimeout(()=>{
			//Only if its active and not busy
			if(tr.hasClass("active") && !isbusy(tr))commit(tbl, tr, port, commitout);
		}, 50);
	});
	
	//Add keyboard functionality
	tr.on("keydown", function(evnt){
		busyadd($(this));
		let target = $(evnt.target);
		let key = evnt.code;
		switch(key){
			//On < select the prior node
			case "ArrowLeft":
				if(target.is("select"))evnt.preventDefault();
				if(evnt.target.selectionStart==undefined||evnt.target.selectionStart==0)
					target.parent().prev().find("*:first").focus();
				break;
			//On > or Tab select the next node
			case "Tab":
			case "ArrowRight":
				if(target.is("select"))evnt.preventDefault();
				if(evnt.target.selectionStart==undefined||evnt.target.selectionStart==target.val().length)
					target.parent().next().find("*:first").focus();
				break;
			//Destroy if escape
			case "Escape":
				discard(tbl, $(this), port);
				break;
			case "Enter":
				commit(tbl, $(this), port, commitout);
				break;
		}
	});
}

function addRow(tbl, port, commitout=true){
	let input=tbl.find("table>template").contents().clone();
	tbl.find("tbody").append(input);
	
	mainrow(tbl, port, $(input), commitout);
}