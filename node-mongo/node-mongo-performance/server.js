const cluster = require('cluster');

if (cluster.isMaster) {
	console.log('Master is running');
	
	const numCPUs  = require('os').cpus().length;
	
    for (let i = 0; i < numCPUs; i++) {
		cluster.fork();
	}
	
	cluster.on('exit', (worker, code, signal) => {
		console.log('Worker %d died', cluster.worker.id)
		cluster.fork();
	});
} else {
	const express = require('express')
	const app = express()
	const mongoose = require('mongoose')

	mongoose.connect('mongodb://mongo/performance', { useUnifiedTopology: true, useNewUrlParser: true })
	const db = mongoose.connection
	db.on('error', (error) => console.error(error))
	db.once('open', () => console.log('Worker %d connected to the database', cluster.worker.id))

	app.use(express.json())

	const peopleRouter = require('./routes/people')
	app.use('/people', peopleRouter)

	const plaintextRouter = require('./routes/plaintext')
	app.use('/plaintext', plaintextRouter)

	const fibonacciRouter = require('./routes/fibonacci')
	app.use('/fibonacci', fibonacciRouter)

	app.listen(3000, () => console.log('Worker %d started', cluster.worker.id))
}