# Asset Generator

A modern Rails application for generating AI-powered images with custom styles and variations. This application provides an intuitive interface for creating, managing, and organizing AI-generated assets using OpenAI's image generation capabilities.

## 🎨 Features

- **Style Management**: Create and manage custom AI prompts and styles
- **Image Generation**: Generate AI images using OpenAI's DALL-E
- **Image Variations**: Create variations of existing images
- **Modern UI**: Beautiful, responsive interface built with Tailwind CSS
- **Dashboard**: Real-time statistics and quick access to all features
- **Gallery**: Browse and organize all generated images

## 🛠️ Technology Stack

- **Backend**: Ruby on Rails 8+
- **Frontend**: Tailwind CSS, Stimulus (Hotwire)
- **Database**: SQLite (development), PostgreSQL (production)
- **AI Integration**: OpenAI API (DALL-E)
- **Testing**: RSpec
- **Deployment**: Docker, Kamal

## 📋 Prerequisites

- Ruby 3.0+
- Rails 7.0+
- Node.js 16+
- SQLite3 (development)
- OpenAI API key

## 🚀 Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd asset-generator
bin/setup
```

### 2. Environment Configuration

Create a `.env` file in the root directory:

```env
OPENAI_API_KEY=your_openai_api_key_here
RAILS_MASTER_KEY=your_rails_master_key
```

### 3. Database Setup

```bash
rails db:create
rails db:migrate
rails db:seed
```

### 4. Install Dependencies

```bash
bundle install
npm install
```

### 5. Start the Application

```bash
bin/dev
```

The application will be available at `http://localhost:3000`

## 🏗️ Data Models

The application is built around five core models:

### Style
- **Purpose**: Template for AI image generation
- **Attributes**:
  - `title` (string): Human-readable name
  - `prompt` (text): Base AI prompt for image generation

### ImageRequest
- **Purpose**: Specific request to generate an image
- **Attributes**:
  - `prompt` (text): Custom prompt for this request
- **Relationships**:
  - `belongs_to :style`

### Image
- **Purpose**: Generated AI image result
- **Relationships**:
  - `belongs_to :image_request` (optional)

### Variation
- **Purpose**: Alternative version of an existing image
- **Relationships**:
  - `belongs_to :image` (parent image)

### VariationRequest
- **Purpose**: Request to create image variations
- **Relationships**:
  - `belongs_to :variation`

## 🎯 Usage Guide

### Creating Styles
1. Navigate to the Styles section
2. Click "Create New Style"
3. Enter a descriptive title and base prompt
4. Save to use for image generation

### Generating Images
1. Go to the Dashboard or Images section
2. Click "Generate Image"
3. Select a style or enter a custom prompt
4. Submit the request
5. View the generated image in the gallery

### Creating Variations
1. Find an existing image in the gallery
2. Click "Create Variation"
3. The system will generate alternative versions
4. View all variations in the Variations section

## 🎨 UI Components

### Dashboard
- Statistics overview
- Quick action buttons
- Recent images gallery
- Navigation to all sections

### Navigation
- Clean, modern navigation bar
- Mobile-responsive design
- Visual indicators for active sections

### Cards and Forms
- Consistent card-based layouts
- Form validation and error handling
- Loading states and feedback

### Responsive Design
- Mobile-first approach
- Tablet and desktop optimized
- Touch-friendly interface

## 🔧 Development

### Running Tests

```bash
# Run all tests
bundle exec rspec

# Run specific test files
bundle exec rspec spec/models/
bundle exec rspec spec/controllers/
```

### Code Quality

```bash
# Run RuboCop for Ruby code style
bundle exec rubocop

# Run Brakeman for security analysis
bundle exec brakeman
```

### Development Server

```bash
# Start with hot reloading
bin/dev

# Or start individual services
rails server
./bin/rails tailwindcss:watch
```

## 🚀 Deployment

### Using Docker

```bash
# Build the image
docker build -t asset-generator .

# Run the container
docker run -p 3000:3000 -e OPENAI_API_KEY=your_key asset-generator
```

### Using Kamal

```bash
# Setup deployment
kamal setup

# Deploy updates
kamal deploy
```

## 🔑 Configuration

### OpenAI Integration
Configure OpenAI settings in `config/initializers/openai.rb`:

```ruby
OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.openai_api_key
  config.organization_id = Rails.application.credentials.openai_organization_id # Optional
end
```

### Tailwind CSS
Tailwind configuration is in `tailwind.config.js`. Custom styles are defined in `app/assets/stylesheets/application.tailwind.css`.

## 📝 API Endpoints

### RESTful Routes
- `GET /` - Dashboard
- `GET /styles` - List all styles
- `POST /styles` - Create new style
- `GET /images` - Image gallery
- `POST /image_requests` - Generate new image
- `GET /variations` - List variations
- `POST /variation_requests` - Create variation

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Check the documentation
- Review the code examples in the application

## 🔮 Future Enhancements

- [ ] User authentication and authorization
- [ ] Image editing and filters
- [ ] Batch image generation
- [ ] Integration with other AI providers
- [ ] Advanced style templates
- [ ] Image sharing and collaboration
- [ ] API for external integrations
- [ ] Image optimization and compression
