/*eslint-env jquery*/
/*ecmaVersion 17*/
/*plugins classPrivateMethods*/
class port{
	id;
	queue;
	ready;
	
	constructor(id){
		this.id=id;
		this.queue=[];
		this.ready=true;
	}
	
	async #innersend(senddata){
		this.ready=false;
		console.log("sending", senddata);
		this.#rawsend(senddata);
		let recdata=await this.#rawrecive();
		console.log("got", recdata);
		this.ready=true;
		return recdata;
	}
	
	async send(senddata){
		let recdata;
		if(this.ready){
			recdata = await this.#innersend(senddata);
		}
		else{
			let p={};
			p.promise=new Promise(resolve=>{
				p.resolve=resolve;
			});
			this.queue.push(p);
			
			await p;
			recdata = await this.#innersend(senddata);
		}
		if(!this.ready)console.warn(`port@${this.id}: send is not ready when it should be`);
		let next=this.queue.shift();
		if(next) next.resolve("You got this!");
		
		return recdata;
	}
	
	#rawsend(data){
		Shiny.setInputValue(this.id, data, {priority: "event"});
		// observeEvent(input$id, func)
	}
	
	// {status: "resolve"|"reject", data:{}}
	async #rawrecive(){
		
		// session$sendCustomMessage(type, message)
		
		let message = await new Promise((resolve,reject)=>{
			Shiny.addCustomMessageHandler(this.id, m=>{
				resolve(m);
			});
		});
		
		Shiny.addCustomMessageHandler(
			this.id, m=>console.warn(`Ignoring input ${this.id}`, message)
		);
		
		return message;
	}
}

class crudport extends port{
	
	constructor(id){
		super(id);
	}
	
	// {action:"create", data:{col1:val1, col2:val2, ... coln:valn}}
	async create(data){
		return await super.send(
			{
				action : "create",
				data : data
			}
		);
	}
	
	// {
	//	action:"update",
	//	where:{
	//		ID:value | 
	//		ID:[value, ">" | "<" | ">=" | "<=" | "=", "&" | "|"],
	//		...
	//	},
	//	data:{
	//		col1:val1, col2:val2, ... coln:valn
	//	}
	//}
	async update(where, data){
		 return await super.send(
			{
				action : "update",
				where : where,
				data: data
			}
		);
	}
	
	// {
	//	action:"remove",
	//	where:{
	//		ID:value | 
	//		ID:[value, ">" | "<" | ">=" | "<=" | "=", "&" | "|"],
	//		...
	//	}
	//}
	async remove(where){
		return await super.send(
			{
				action : "remove",
				where : where
			}
		);
	}
	
	async read(where){
		return await super.send(
			{
				action : "read",
				where : where
			}
		);
	}
}

// Builds the data to be sent to the server
function build(tr, usedata=false){
	let row=tr.find("td:not(.ecl)");
	var data={};
	for(let td of row){
		let head = $("#"+$(td).data("col"));
		let val;
		if(usedata)val=$(td).data("val");
		else val = $(td).find("*:first").val();
		data[head.data("col")]=val;
	}
	return data;
}

//	where:{
//		ID:value | 
//		ID:[value, ">" | "<" | ">=" | "<=" | "=", "&" | "|"],
//		...
//	}
function buildWhere(data, tbl){
	let keys=tbl.find("table").data("keys").split(/[|,;:]/);
	let where={};
	for(let key of keys){
		if(data[key]!=undefined)where[key]=data[key];
	}
	return where;
}