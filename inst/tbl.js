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

// Function to escape HTML entities
function escapeHTML(unsafe) {
	// Convert the input to a string and replace HTML entities
	return String(unsafe).replace(/[&<"'>]/g, m=>{
		// Use a switch statement to match each entity
		switch(m){
			case '&':
				// Replace '&' with its HTML entity
				return '&';
			case '<':
				// Replace '<' with its HTML entity
				return '<';
			case '>':
				// Replace '>' with its HTML entity
				return '>';
			case '"':
				// Replace '"' (double quote) with its HTML entity
				return '"';
			case "'":
				// Replace "'" (single quote) with its HTML entity
				return ''';
		}
	});
}


function write(tbl, el, val){
		rawWrite(el, val);
		render(tbl, el, val);
}

function rawWrite(el, val){
	el.data("val", val);
}

/**
 * @brief Reads the data value of an element.
 * 
 * @param el The element to read the data from.
 * 
 * @return The data value of the element.
 */
function read(el){
	return el.data("val");
}

/**
 * @brief Applies a type function to a value.
 * 
 * @param typefun The object containing the type functions.
 * @param col The column name.
 * @param type The type of the value.
 * @param val The value to apply the type function to.
 * 
 * @return The result of applying the type function to the value.
 */
function applyTypeFun(typefun, col, type, val){
	if(typefun[col] !== undefined) return typefuncol
	if(typefun[type] !== undefined) return typefuntype
	typefun = evalName()
	if(typefun[type] !== undefined) return typefuntype
	return val
}

/**
 * @brief Renders a table cell.
 * 
 * @param tbl The table element.
 * @param el The table cell element.
 * @param val The value to render in the table cell.
 */
function render(tbl, el, val=read(el)){
	if(val===null)el.append("<div></div>");
	else{
		else rawWrite(el, val);
		let head=$(`#${el.data("col")}`);
		let col=head.data("col");
		let type=head.data("type");
		let typefun=evalName(tbl.find("table").data("js"));
		let txt = applyTypeFun(typefun, col, type, val)
		el.append($(`<div>${escapeHTML(txt)}</div>`));
	}
}


/**
 * @function busyadd
 * @description This function increments the 'busy' data attribute of an element.
 * If 'busy' is not set, it defaults to 0+1. It then sets a timeout to call the 
 * 'busysub' function after 100 milliseconds.
 * @param {Object} el - The element whose 'busy' attribute is to be incremented.
 */
function busyadd(el){
		// Increment the 'busy' data attribute by 1
		// If 'busy' is not set, it defaults to 0+1
		el.data("busy", (el.data("busy")||0)+1);
		
		// Set a timeout to call the 'busysub' function after 100 milliseconds
		setTimeout(()=>busysub(el), 100);
}

/**
 * @function busysub
 * @description This function decrements the 'busy' data attribute of an element.
 * If 'busy' is not set, it defaults to 0.
 * @param {Object} el - The element whose 'busy' attribute is to be decremented.
 */
function busysub(el){
		// Decrement the 'busy' data attribute by 1
		// If 'busy' is not set, it defaults to 0
		el.data("busy", (el.data("busy")||0)-1);
}

/**
 * @function isbusy
 * @description This function checks if an element is 'busy'. It returns true if 
 * the 'busy' data attribute is greater than 0.
 * @param {Object} el - The element to check.
 * @returns {boolean} - Returns true if the element is busy, false otherwise.
 */
function isbusy(el){
		// Return true if the 'busy' data attribute is greater than 0
		return el.data("busy")>0;
}

/**
 * @function update
 * @description This function updates the content of a table row (`tr`) in a table (`tbl`) 
 * based on the provided `data` parameter.
 * @param {Object} tbl - The HTML table to be updated.
 * @param {Object} tr - The table row to be updated.
 * @param {string|Object} [data="data-val"] - The data to be used for the update. It can be 
 * a string ("null", "val", "data-val") or an object.
 * 
 * @details
 * The function checks the value of `data` and performs different actions based on its value:
 * - If `data` is "null", it empties each cell in the row and writes `null` to it.
 * - If `data` is "val", it retrieves the value of the first child element in each cell, 
 *   empties the cell, and then writes the retrieved value back to the cell.
 * - If `data` is "data-val", it reads the current value of each cell, empties the cell, 
 *   and then writes the read value back to the cell.
 * - If `data` is none of the above, it assumes `data` is an object. It then iterates over 
 *   each cell in the row. For each cell, it finds the corresponding property in the `data` 
 *   object (the property name is retrieved from the cell's "col" data attribute). If the 
 *   property exists in the `data` object, it writes the property's value to the cell. If 
 *   the property's value is an array, it writes the first element of the array to the cell.
 */
function update(tbl, tr, data="data-val"){
	tr.find("td:not(.ecl)").each(function(){
		let td=$(this);
		let val;
		if(data === "null")val = null;
		else if(data === "val")val = td.find("*:first").val();
		else if(data === "data-val")val = read(td);
		else{
			let col = tbl.find("#" + td.data("col")).data("col");
			if (data[col] !== undefined) {
				if (data[col][0] === undefined) val = data[col];
				else val = data[col][0];
			}
			else val = undefined;
		}
		if(val !== undefined) {
			td.empty();
			write(tbl, td, val);
		}
	});
}


/**
 * @function resolve
 * @description This function displays success in an HTML table row by adding a 
 * success class (default is "bg-success") to the row. The success class is 
 * removed after a specified delay.
 * @param {Object} tr - The table row to display success.
 * @param {string} [clas="bg-success"] - The class to add to the row to 
 * indicate success. Defaults to "bg-success".
 * @param {number} [delay=5000] - The delay in milliseconds before the success 
 * class is removed. Defaults to 5000.
 * 
 * @details
 * The function adds the success class to the given table row 'tr'. It then 
 * sets a timeout to remove the success class after the specified delay.
 */
function resolve(tr, clas="bg-success", delay=5000){
	tr.addClass(clas);
	setTimeout(function(){
		tr.removeClass(clas);
	}, delay);
}

/**
 * @function dispError
 * @description This function displays an error message in a table row.
 * @param {Object} tr - The table row where the error occurred.
 * @param {string} message - The error message to display.
 * 
 * @details
 * The function creates a new table row element with the error message and a 
 * 'bg-danger' class to highlight it. It then inserts this new element before 
 * the given table row 'tr'. If you want the error message to disappear after 
 * 5 seconds, uncomment the setTimeout line.
 */
function dispError(tr, message){
	// Create a new table row element with the error message
	let el=$(`<tr class="bg-danger error msg"><td colspan="9999">${message}</tr></td>`);
	
	// Add the 'bg-danger' class to the element to highlight it
	el.addClass("bg-danger");
	
	// Insert the new element before the given table row 'tr'
	el.insertBefore(tr);
	
	// Uncomment the following line if you want the error message to disappear after 5 seconds
	//setTimeout(()=>el.remove(), 5000);
}

/**
 * @function clearError
 * @description This function clears the error message from a table row.
 * @param {Object} tr - The table row from which to clear the error.
 * 
 * @details
 * The function first removes the 'bg-danger' class from the given table row 'tr'. 
 * It then gets the previous sibling element of 'tr' and loops while the previous 
 * sibling element has the classes 'error' and 'msg'. For each such element, it 
 * removes the element from the DOM.
 */
function clearError(tr){
	// Remove the 'bg-danger' class from the given table row 'tr'
	tr.removeClass("bg-danger");
	
	// Get the previous sibling element of 'tr'
	tr=tr.prev();
	
	// Loop while the previous sibling element has the classes 'error' and 'msg'
	while(tr.is(".error.msg")){
		// Store the current element in 'el'
		let el=tr;
		
		// Update 'tr' to its previous sibling element
		tr=tr.prev();
		
		// Remove the current element from the DOM
		el.remove();
	}
}

async function commit(tbl, tr, port=undefined, onClickOff="commit"){
	//build(tr)
	if(port !== undefined){
		let data=build(tr);
		let where = buildWhere(data, tbl);
		
		var message;
		// This will never be called if the addRow has never been called before
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
			addRow(tbl, port, onClickOff);
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

/**
 * @function create
 * @description This function creates an interactive row in an HTML table,
 * which represents an SQL record.
 * @param {Object} tbl - The HTML table to modify as a jQuery element.
 * @param {Object} tr - The table row to make interactive.
 * @param {Object} evnt - The HTML event object.
 * @param {Object} [port=undefined] - The port object used for communication
 * with the database.
 * @param {string} [onClickOff="commit"] - The action to perform when clicking
 * off the row.
 * 
 * @details
 * The function first checks if the clicked target is a table cell. If not, it
 * sets the target to the parent of the clicked element. It then checks if the
 * row is already active. If not, it commits all other active rows in the table,
 * sets the row to active, and makes each cell in the row interactive by
 * replacing the cell content with an input field. The input field is populated
 * with the existing text from the cell. The function then sets focus on the
 * clicked element. If the clicked element is disabled, it sets focus on the
 * next enabled element. If the row is already active, it calls the busyadd
 * function on the row.
 */
function create(tbl, tr, evnt, port=undefined, onClickOff="commit"){
	// ... function body ...
}

function create(tbl, tr, evnt, port=undefined, onClickOff="commit"){
	let target=$(evnt.target);
	if(!target.is("td"))target=target.parent();
	tr=$(tr);
	//Only if it isnt active
	if(!tr.hasClass("active")){
		tbl.find("tbody tr.active").each(function(){
			commit(tbl, $(this), port, onClickOff);
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

/**
 * @async
 * @function discard
 * @description This function discards an SQL record from an HTML table.
 * @param {Object} tbl - The HTML table from which the record is to be discarded.
 * @param {Object} tr - The table row representing the record to be discarded.
 * @param {Object} port - The port object used for communication with the database.
 * 
 * @returns {Promise} This function is asynchronous and returns a Promise.
 * 
 * @details
 * If the table row does not have the class "new-tr", the function builds a WHERE clause for an SQL query using the data in the row and the table structure. It then sends a read request to the database using the port. If the request is rejected, it logs an error message and displays the error on the table row. If the request is resolved, it empties each cell in the row and updates the row with the data received from the database.
 * 
 * If the table row has the class "new-tr", the function simply empties each cell in the row.
 * 
 * Finally, the function removes the "active" class from the row, clears any error messages, and resolves the row with a "bg-warning" class.
 */
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


function main(tbl, id, onClickOff="commit", addRows = true){
	//Add new port
	var port=new crudport(id);
	if(window.message)console.log(`Added port ${id}: `, port);
	tbl.find("td:not(.ecl)").each(function(){render(tbl, $(this))});
	
	mainrow(tbl, port, tbl.find("tr"), onClickOff);
	if(addRows)addRow(tbl, port, onClickOff);
}

// Function to handle main row interactions
function mainrow(tbl, port, tr, onClickOff="commit"){
	// On click, add an input box if the target is not a button
	tr.on("click", function(e){
		if(!($(e.target).is(".btn") || $(e.target).parents(".btn").is(".btn")))create(tbl, this, e, port, onClickOff)
	});
	
	// On focus in, add a busy class to the row
	tr.on("focusin", function(evnt){
		busyadd($(this));
	});
	
	// On commit button click, commit the changes
	tr.find("button.commit").on("click", function(evnt){
		commit(tbl, $(this).parents("tr"), port, onClickOff);
	});
	
	// On discard button click, discard the changes
	tr.find("button.discard").on("click", async function(evnt){
		discard(tbl, $(this).parents("tr"), port);
	});
	
	// On remove button click, confirm and remove the row
	tr.find("button.remove").on("click", async function(evnt){
		var tr=$(this).parents("tr");
		async function conf(tr){
			let where = buildWhere(build(tr, true), tbl);
			let message=await port.remove(where);
			if(message.status=="reject"){
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
	
	// On click off, destroy the inputs and commit or discard based on the setting
	if(onClickOff=="commit")tr.on("focusout", function(evnt){
		let tr=$(this);
		setTimeout(()=>{
			// Only if its active and not busy
			if(tr.hasClass("active") && !isbusy(tr))commit(tbl, tr, port, onClickOff);
		}, 50);
	});
	else if(onClickOff=="discard")tr.on("focusout", function(evnt){
		let tr=$(this);
		setTimeout(()=>{
			// Only if its active and not busy
			if(tr.hasClass("active") && !isbusy(tr))discard(tbl, tr, port);
		}, 50);
	});
	
	// Add keyboard functionality for navigation and actions
	tr.on("keydown", function(evnt){
		busyadd($(this));
		let target = $(evnt.target);
		let key = evnt.code;
		switch(key){
			// On < select the prior node
			case "ArrowLeft":
				// If the target element is a select box, prevent the default event action
				if(target.is("select"))evnt.preventDefault();

				// If the target element does not have a selection start property (meaning it's not a text input or textarea)
				// or if the selection start is at the beginning of the input value (meaning the cursor is at the start of the text)
				if(evnt.target.selectionStart==undefined||evnt.target.selectionStart==0)
					// Focus on the first child element of the previous sibling of the parent of the target element
					target.parent().prev().find("*:first").focus();

				break;
			// On > or Tab select the next node
			case "Tab":
				// Fallthrough
			case "ArrowRight":
				// If the target element is a select box, prevent the default event action
				if(target.is("select"))evnt.preventDefault();

				// If the target element does not have a selection start property (meaning it's not a text input or textarea)
				// or if the selection start is at the end of the input value (meaning the cursor is at the end of the text)
				if(evnt.target.selectionStart==undefined||evnt.target.selectionStart==target.val().length)
					// Focus on the first child element of the next sibling of the parent of the target element
					target.parent().next().find("*:first").focus();

				break;
			// Destroy if escape
			case "Escape":
				discard(tbl, $(this), port);
				break;
			// Commit if enter
			case "Enter":
				commit(tbl, $(this), port, onClickOff);
				break;
		}
	});
}


function addRow(tbl, port, onClickOff="commit"){
	let input=tbl.find("table>template").contents().clone();
	tbl.find("tbody").append(input);
	
	mainrow(tbl, port, $(input), onClickOff);
}