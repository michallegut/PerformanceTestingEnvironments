const express = require('express')
const router = express.Router()

router.get('/', async (req, res) => {
    res.send('Fiorentine macaroni tortellini pastina, cheesy al dente basil angel hair lasagna linguini linguini. Linguini basil spaghetti ditalini anelli fettuccine vermicelli. Fiorentine al dente cavatelli lasagna sorprese tomatoes, cavatelli linguini capellini spaghetti anelli. Cavatelli tomatoes ravioli ziti carbonara cheesy penne spaghetti. Sauce ziti ziti anelli ditalini sorprese tomatoes macaroni. Sauce carbonara ravioli tomatoes fiorentine cheesy anelli ditalini. Macaroni carbonara al dente tomatoes tripoline sauce pasta, delicious spaghetti ziti cavatelli. Lasagna tortellini ziti macaroni basil tortellini anelli pasta. Delicious al dente spaghettini tortellini sorprese cheesy ziti, tripoline fettuccine tripoline tripoline fiorentine tortellini.')
})

module.exports = router