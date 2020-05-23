const express = require('express')
const router = express.Router()
const Person = require('../models').person
const data = require('../data.json');

router.get('/', async (req, res) => {
    try {
        const people = await Person.findAll()
        res.json(people)
    } catch (err) {
        res.status(500).json({ message: err.message })
    }
})

router.get('/:id', getPerson, (req, res) => {
    res.json(res.person)
})

router.post('/', async (req, res) => {
    try {
        const createdPerson = await Person.create({
            firstName: req.body.firstName,
            lastName: req.body.lastName,
            email: req.body.email
        })
        res.json(createdPerson)
    } catch (err) {
        res.status(400).json({ message: err.message })
    }
})

router.patch('/:id', getPerson, async (req, res) => {
    if (req.body.firstName != null) {
        res.person.firstName = req.body.firstName
    }
    if (req.body.lastName != null) {
        res.person.lastName = req.body.lastName
    }
    if (req.body.email != null) {
        res.person.email = req.body.email
    }

    try {
        const updatedPerson = await Person.update({
            firstName: res.person.firstName,
            lastName: res.person.lastName,
            email: res.person.email
        }, {
            where: {
                id: res.person.id
            }
        })
        res.json(res.person)
    } catch (err) {
        res.status(400).json({ message: err.message })
    }
})

router.delete('/:id', getPerson, async (req, res) => {
    try {
        const deletedPerson = await Person.destroy({
            where: {
                id: res.person.id
            }
        })
        res.json(res.person)
    } catch (err) {
        res.status(500).json({ message: err.message })
    }
})

router.post('/reset', async (req, res) => {
    try {
        await Person.destroy({
            where: {},
            truncate: true
          })
		await Person.bulkCreate(data)
        res.end()
    } catch (err) {
        res.status(500).json({ message: err.message })
    }
})

async function getPerson(req, res, next) {
    try {
        person = await Person.findByPk(req.params.id)
        if (person == null) {
            return res.status(404).json({ message: 'Not Found' })
        }
    } catch (err) {
        return res.status(500).json({ message: err.message })
    }

    res.person = person
    next()
}

module.exports = router