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
	const bodyParser = require('body-parser')

	app.use(bodyParser.json())
	app.use(bodyParser.urlencoded({ extended: false }));

	const peopleRouter = require('./routes/people')
	app.use('/people', peopleRouter)

	const plaintextRouter = require('./routes/plaintext')
	app.use('/plaintext', plaintextRouter)

	const fibonacciRouter = require('./routes/fibonacci')
	app.use('/fibonacci', fibonacciRouter)

	app.listen(3000, () => console.log('Worker %d started', cluster.worker.id))
}