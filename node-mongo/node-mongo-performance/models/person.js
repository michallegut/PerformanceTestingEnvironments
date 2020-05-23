const mongoose = require('mongoose')

const personSchema = new mongoose.Schema({
    firstName: String,
    lastName: String,
    email: String
}, {
    versionKey: false
})

personSchema.set('toJSON', {
    virtuals: true,
    transform: function (doc, ret, options) {
        delete ret._id
    }
});


module.exports = mongoose.model('Person', personSchema)