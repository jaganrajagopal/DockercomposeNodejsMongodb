const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

const app = express();
const port = 3000;

app.use(bodyParser.json());

const RecordSchema = new mongoose.Schema({
  name: String,
  value: String
});

const Record = mongoose.model('Record', RecordSchema);

// MongoDB URL
const mongoURI = 'mongodb://mongo:27017/mydb';

// Connect to MongoDB
mongoose.connect(mongoURI, { useNewUrlParser: true, useUnifiedTopology: true })
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.log(err));

app.get('/records', async (req, res) => {
try {
    const records = await Record.find();
    res.status(200).json(records);
} catch (error) {
    res.status(500).json({ error: 'Internal server error' });
}
});  

app.post('/records', async (req, res) => {
  const { name, value } = req.body;
  const newRecord = new Record({ name, value });

  try {
    await newRecord.save();
    res.status(201).send(newRecord);
  } catch (error) {
    res.status(400).send(error);
  }
});

app.listen(port, () => console.log(`Server running on port ${port}`));
