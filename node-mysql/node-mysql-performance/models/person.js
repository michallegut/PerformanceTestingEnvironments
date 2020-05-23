module.exports = (sequelize, DataTypes) => {
    let person = sequelize.define('person', {
        id: {
            type: DataTypes.UUID,
            defaultValue: DataTypes.UUIDV4,
            allowNull: false,
            primaryKey: true
        },
        firstName: {
            type: DataTypes.STRING,
            field: "first_name"
        },
        lastName: {
            type: DataTypes.STRING,
            field: "last_name"
        },
        email: DataTypes.STRING

    }, {
        timestamps: false
    });
    return person
}