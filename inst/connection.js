/*eslint-env jquery*/
/*ecmaVersion 17*/
/*plugins classPrivateMethods*/
/**
 * @class port
 * @brief This class represents a port.
 * 
 * @details A port has an id, a queue, and a ready state. It can send and receive data.
 * This code defines a port class for managing a connection with R using the Shiny package.
 * The class has methods for sending and receiving data, and it manages a queue to handle multiple send requests. 
 * It uses the Shiny package’s setInputValue and addCustomMessageHandler methods to send and receive data. 
 * The #innersend and #rawrecive methods are private methods used internally by the class.
 * The send method is the public interface for sending data.
 * It checks if the port is ready before sending data, and if it’s not,
 * it adds the send request to a queue to be processed later.
 * The #rawsend method is a private method that sends raw data to R.
 * The #rawrecive method is a private method that receives raw data from R.
 * The received data is returned as a promise that resolves when the data is received.
 * If any additional data is received after the promise has resolved, a warning message is logged.
 */
class port{
	/** @brief The id of the port. */
	id;
	
	/** @brief The queue of the port. */
	queue;
	
	/** @brief The ready state of the port. */
	ready;
	
	/**
	 * @brief Constructs a new port object.
	 * 
	 * @param id The id of the port.
	 */
	constructor(id){
		this.id=id; // Initialize the id of the port.
		this.queue=[]; // Initialize the queue of the port as an empty array.
		this.ready=true; // Initialize the ready state of the port as true.
	}
	
	/**
	 * @brief Sends data and updates the ready state.
	 * 
	 * @param senddata The data to be sent.
	 * 
	 * @return The received data.
	 * 
	 * @note This is a private method.
	 */
	async #innersend(senddata){
		this.ready=false; // Set the ready state to false before sending data.
		if(window.message)console.log("sending", senddata); // If window.message exists, log the data being sent.
		this.#rawsend(senddata); // Call the private method to send raw data.
		let recdata=await this.#rawrecive(); // Wait for the private method to receive raw data and store it in recdata.
		if(window.message)console.log("got", recdata); // If window.message exists, log the received data.
		this.ready=true; // Set the ready state to true after receiving data.
		return recdata; // Return the received data.
	}
	
	// {status: "resolve"|"reject", data:{}}
	/**
	 * @brief Sends data and manages the queue.
	 * 
	 * @param senddata The data to be sent.
	 * 
	 * @return The received data.
	 */
	async send(senddata){
		let recdata; // Declare a variable to hold the received data.
		if(this.ready){ // If the port is ready,
			recdata = await this.#innersend(senddata); // call the private method to send data and store the received data in recdata.
		}
		else{ // If the port is not ready,
			let p={}; // declare an object p.
			p.promise=new Promise(resolve=>{ // Create a new promise and assign it to the promise property of p.
				p.resolve=resolve; // Assign the resolve function to the resolve property of p.
			});
			this.queue.push(p); // Push the object p into the queue.
			
			await p; // Wait for the promise in p to be resolved.
			recdata = await this.#innersend(senddata); // Call the private method to send data and store the received data in recdata.
		}
		if(!this.ready)console.warn(`port@${this.id}: send is not ready when it should be`); // If the port is not ready, log a warning message.
		let next=this.queue.shift(); // Remove the first element from the queue and store it in next.
		if(next) next.resolve("You got this!"); // If next exists, call its resolve function.
		
		return recdata;
	}
	
	/**
	 * @brief Sends raw data.
	 * 
	 * @param data The data to be sent.
	 * 
	 * @note This is a private method.
	 */
	#rawsend(data){ 
		Shiny.setInputValue(this.id, data, {priority: "event"}); // Call the setInputValue method of Shiny to send data.
		// observeEvent(input$id, func)
	}
	
	/**
	 * @brief Receives raw data.
	 * 
	 * @return The received message.
	 * 
	 * @note This is a private method.
	 */
	async #rawrecive(){ // Define a private asynchronous method to receive raw data.
		
		// session$sendCustomMessage(type, message)
		
		let message = await new Promise((resolve,reject)=>{ // Create a new promise to receive a message and store it in message.
			Shiny.addCustomMessageHandler(this.id, m=>{ // Call the addCustomMessageHandler method of Shiny to handle a custom message.
				resolve(m); // Resolve the promise with the received message.
			});
		});
		
		Shiny.addCustomMessageHandler( // Call the addCustomMessageHandler method of Shiny to handle a custom message.
			this.id, m=>console.warn(`Ignoring input ${this.id}`, message) // Log a warning message if a message is received.
		);
		
		return message;
	}
}



/**
 * @class crudport
 * @brief This class represents a CRUD (Create, Read, Update, Delete) port.
 * 
 * @details A crudport extends the port class and adds methods for creating, reading, updating, and deleting data.
 * 
 * @extends port
 */
class crudport extends port{
	
	/**
	 * @brief Constructs a new crudport object.
	 * 
	 * @param id The id of the crudport.
	 */
	constructor(id){
		super(id);
	}
	
	/**
	 * @brief Sends a create action.
	 * 
	 * @param data The data to be created.
	 * 
	 * @return The received data.
	 */
	async create(data){
		return await super.send(
			{
				action : "create",
				data : data
			}
		);
	}
	
	/**
	 * @brief Sends an update action.
	 * 
	 * @param where The conditions for the update.
	 * @param data The data to be updated.
	 * 
	 * @return The received data.
	 */
	async update(where, data){
		 return await super.send(
			{
				action : "update",
				where : where,
				data: data
			}
		);
	}
	
	/**
	 * @brief Sends a remove action.
	 * 
	 * @param where The conditions for the removal.
	 * 
	 * @return The received data.
	 */
	async remove(where){
		return await super.send(
			{
				action : "remove",
				where : where
			}
		);
	}
	
	/**
	 * @brief Sends a read action.
	 * 
	 * @param where The conditions for the read.
	 * 
	 * @return The received data.
	 */
	async read(where){
		return await super.send(
			{
				action : "read",
				where : where
			}
		);
	}
}


/**
 * @brief Builds the data to be sent to the server.
 * 
 * @param tr The table row element.
 * @param usedata A boolean indicating whether to use the data attribute of the cell.
 * 
 * @return An object containing the data to be sent.
 */
function build(tr, usedata=false){
	// Find all table data cells in the row that do not have the 'ecl' class
	let row=tr.find("td:not(.ecl)");
	// Initialize an empty object to store the data
	var data={};
	// Loop over each table data cell
	for(let td of row){
		// Get the corresponding table header element
		let head = $("#"+$(td).data("col"));
		// Get the value from the data attribute or the first child element
		let val;
		if(usedata)val=$(td).data("val");
		else val = $(td).find("*:first").val();
		// Add the value to the data object with the column name as the key
		data[head.data("col")]=val;
	}
	// Return the data object
	return data;
}

/**
 * @brief Builds the where clause for a database query.
 * 
 * @param data An object containing the data for the where clause.
 * @param tbl The table element.
 * 
 * @return An object containing the where clause.
 */
function buildWhere(data, tbl){
	// Get the keys from the table's data attribute and split them into an array
	let keys=tbl.find("table").data("keys").split(/[|,;:]/);
	// Initialize an empty object to store the where clause
	let where={};
	// Loop over each key
	for(let key of keys){
		// If the key exists in the data object, add it to the where clause
		if(data[key]!=undefined)where[key]=data[key];
	}
	// Return the where clause
	return where;
}