#!/bin/bash

# Function to display status messages
print_message() {
    echo "====================================="
    echo "$1"
    echo "====================================="
}

# Set project name and base directory
PROJECT_NAME="event-registration"
BASE_DIR=$(pwd)/$PROJECT_NAME

# Create project directory structure
print_message "Creating project folder structure..."
mkdir -p $BASE_DIR/{public/{css,js,images,uploads},views}

# Navigate to project directory
cd $BASE_DIR

# Initialize Node.js project
print_message "Initializing Node.js project..."
npm init -y > /dev/null

# Install required dependencies
print_message "Installing dependencies..."
npm install express mongoose multer ejs bootstrap > /dev/null

# Create server.js file
print_message "Creating server.js file..."
cat > server.js <<EOL
const express = require('express');
const mongoose = require('mongoose');
const multer = require('multer');
const app = express();

// Middleware setup
app.set('view engine', 'ejs');
app.use(express.static('public'));
app.use(express.urlencoded({ extended: true }));

// MongoDB connection
mongoose.connect('mongodb://127.0.0.1:27017/eventDB', { useNewUrlParser: true, useUnifiedTopology: true });

// Schemas
const eventSchema = new mongoose.Schema({ name: String, description: String });
const registrationSchema = new mongoose.Schema({
    name: String,
    email: String,
    date: String,
    image: String,
    message: String,
    eventId: mongoose.Schema.Types.ObjectId,
});

const Event = mongoose.model('Event', eventSchema);
const Registration = mongoose.model('Registration', registrationSchema);

// File upload setup
const upload = multer({ dest: 'public/uploads/' });

// Routes
app.get('/login', (req, res) => res.render('login'));

app.get('/home', async (req, res) => {
    const events = await Event.find();
    res.render('home', { events });
});

app.get('/register/:id', (req, res) => res.render('register', { eventId: req.params.id }));

app.post('/submit-registration', upload.single('image'), async (req, res) => {
    const { name, email, date, message, eventId } = req.body;
    const newReg = new Registration({ name, email, date, message, eventId, image: req.file?.path });
    await newReg.save();
    res.redirect('/home');
});

app.get('/view/:id', async (req, res) => {
    const registrations = await Registration.find({ eventId: req.params.id });
    res.render('viewRegistrations', { registrations });
});

// Start server
app.listen(3000, () => console.log('Server started on http://localhost:3000'));
EOL

# Create EJS templates
print_message "Creating EJS templates..."

cat > views/login.ejs <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Login</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container text-center mt-5">
    <h2>Welcome to Event Registration</h2>
    <a href="/home" class="btn btn-primary mt-3">Skip Login</a>
</div>
</body>
</html>
EOL

cat > views/home.ejs <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Events</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2 class="text-center">Available Events</h2>
    <div class="row">
        <% events.forEach(event => { %>
        <div class="col-md-4">
            <div class="card mt-3">
                <div class="card-body">
                    <h5 class="card-title"><%= event.name %></h5>
                    <p class="card-text"><%= event.description %></p>
                    <a href="/register/<%= event._id %>" class="btn btn-success">Register</a>
                    <a href="/view/<%= event._id %>" class="btn btn-secondary">View Registrations</a>
                </div>
            </div>
        </div>
        <% }) %>
    </div>
</div>
</body>
</html>
EOL

cat > views/register.ejs <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Register</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>Register for Event</h2>
    <form action="/submit-registration" method="POST" enctype="multipart/form-data">
        <input type="hidden" name="eventId" value="<%= eventId %>">
        <div class="mb-3">
            <label for="name" class="form-label">Name</label>
            <input type="text" class="form-control" id="name" name="name" required>
        </div>
        <div class="mb-3">
            <label for="email" class="form-label">Email</label>
            <input type="email" class="form-control" id="email" name="email" required>
        </div>
        <div class="mb-3">
            <label for="date" class="form-label">Date of the Event</label>
            <input type="date" class="form-control" id="date" name="date" required>
        </div>
        <div class="mb-3">
            <label for="image" class="form-label">Upload Image (Optional)</label>
            <input type="file" class="form-control" id="image" name="image">
        </div>
        <div class="mb-3">
            <label for="message" class="form-label">Message</label>
            <textarea class="form-control" id="message" name="message"></textarea>
        </div>
        <button type="submit" class="btn btn-primary">Submit</button>
    </form>
</div>
</body>
</html>
EOL

cat > views/viewRegistrations.ejs <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <title>View Registrations</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>Registrations for Event</h2>
    <table class="table">
        <thead>
        <tr>
            <th>Name</th>
            <th>Email</th>
            <th>Date</th>
            <th>Message</th>
        </tr>
        </thead>
        <tbody>
        <% registrations.forEach(reg => { %>
        <tr>
            <td><%= reg.name %></td>
            <td><%= reg.email %></td>
            <td><%= reg.date %></td>
            <td><%= reg.message %></td>
        </tr>
        <% }) %>
        </tbody>
    </table>
</div>
</body>
</html>
EOL

# Completion message
print_message "Project setup complete. Navigate to '$PROJECT_NAME/' and start the server with 'node server.js'."
