const express = require('express')
const router = express.Router()

router.get('/:n', getFibonacciNumber, async (req, res) => {
    res.send(res.fibonacciNumber)
})

async function getFibonacciNumber(req, res, next) {
    if (req.params.n > 0) {
        var previousPreviousNumber, previousNumber = BigInt(0), currentNumber = BigInt(1);
        for (var i = 1; i < req.params.n; i++) {
            previousPreviousNumber = previousNumber;
            previousNumber = currentNumber;
            currentNumber = previousPreviousNumber + previousNumber;
        }
        res.fibonacciNumber = currentNumber.toString()
    } else {
        res.fibonacciNumber = '0'
    }
    next()
}

module.exports = router