import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas", "image", "maskData", "selectedImage"]
  static values = { 
    brushSize: { type: Number, default: 20 },
    mode: { type: String, default: "draw" } // "draw" or "erase"
  }

  connect() {
    this.setupCanvas()
    this.bindEvents()
  }

  setupCanvas() {
    this.canvas = this.canvasTarget
    this.ctx = this.canvas.getContext('2d')
    this.isDrawing = false
    
    // Set canvas style for better visibility
    this.canvas.style.cursor = 'crosshair'
    this.canvas.style.border = '2px solid #e5e7eb'
    this.canvas.style.borderRadius = '8px'
    this.canvas.style.maxWidth = '100%'
    this.canvas.style.height = 'auto'
    this.canvas.style.display = 'block'
    this.canvas.style.margin = '0 auto'
    
    // Set default size until an image is loaded
    this.canvas.width = 400
    this.canvas.height = 300
    
    // Add placeholder text
    this.ctx.fillStyle = '#9ca3af'
    this.ctx.font = '16px system-ui'
    this.ctx.textAlign = 'center'
    this.ctx.fillText('Select an image above to start drawing', this.canvas.width / 2, this.canvas.height / 2)
  }

  bindEvents() {
    // Mouse events
    this.canvas.addEventListener('mousedown', this.startDrawing.bind(this))
    this.canvas.addEventListener('mousemove', this.draw.bind(this))
    this.canvas.addEventListener('mouseup', this.stopDrawing.bind(this))
    this.canvas.addEventListener('mouseout', this.stopDrawing.bind(this))
    
    // Touch events for mobile
    this.canvas.addEventListener('touchstart', this.handleTouch.bind(this))
    this.canvas.addEventListener('touchmove', this.handleTouch.bind(this))
    this.canvas.addEventListener('touchend', this.stopDrawing.bind(this))
  }

  imageSelected(event) {
    const selectedImageElement = event.currentTarget.querySelector('img')
    if (!selectedImageElement) return
    
    this.loadImageToCanvas(selectedImageElement)
  }

  loadImageToCanvas(imgElement) {
    // Create a new image element to avoid CORS issues
    const img = new Image()
    img.crossOrigin = 'anonymous'
    
    img.onload = () => {
      // Store the background image for redrawing
      this.backgroundImage = img
      
      // Calculate canvas dimensions based on image aspect ratio
      const maxCanvasSize = 600 // Maximum size for either width or height
      const imgWidth = img.naturalWidth || img.width
      const imgHeight = img.naturalHeight || img.height
      
      let canvasWidth, canvasHeight
      
      // Calculate dimensions maintaining aspect ratio
      if (imgWidth > imgHeight) {
        // Landscape image
        canvasWidth = Math.min(maxCanvasSize, imgWidth)
        canvasHeight = (canvasWidth / imgWidth) * imgHeight
      } else {
        // Portrait or square image
        canvasHeight = Math.min(maxCanvasSize, imgHeight)
        canvasWidth = (canvasHeight / imgHeight) * imgWidth
      }
      
      // Set canvas dimensions
      this.canvas.width = canvasWidth
      this.canvas.height = canvasHeight
      
      // Update canvas display style to maintain aspect ratio
      this.canvas.style.maxWidth = '100%'
      this.canvas.style.height = 'auto'
      this.canvas.style.display = 'block'
      this.canvas.style.margin = '0 auto'
      
      // Clear canvas first
      this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height)
      
      // Draw the source image at full opacity
      this.ctx.globalAlpha = 1.0
      this.ctx.drawImage(img, 0, 0, this.canvas.width, this.canvas.height)
      
      // Initialize the mask overlay
      this.initializeMask()
    }
    
    img.onerror = () => {
      console.warn('Could not load image for canvas, using default size')
      this.backgroundImage = null
      // Use default size if image fails to load
      this.canvas.width = 512
      this.canvas.height = 512
      this.initializeMask()
    }
    
    // Set the image source
    img.src = imgElement.src
  }

  initializeMask() {
    // Create a separate canvas for the mask overlay
    if (!this.maskCanvas) {
      this.maskCanvas = document.createElement('canvas')
      this.maskCtx = this.maskCanvas.getContext('2d')
    }
    
    this.maskCanvas.width = this.canvas.width
    this.maskCanvas.height = this.canvas.height
    
    // Clear the mask canvas (transparent)
    this.maskCtx.clearRect(0, 0, this.maskCanvas.width, this.maskCanvas.height)
    
    // Redraw the display
    this.redrawCanvas()
    this.updateMaskData()
  }

  redrawCanvas() {
    // Clear the main canvas
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height)
    
    // Draw the background image if available
    if (this.backgroundImage) {
      this.ctx.globalAlpha = 1.0
      this.ctx.drawImage(this.backgroundImage, 0, 0, this.canvas.width, this.canvas.height)
    }
    
    // Draw the mask overlay with red tint for visualization
    if (this.maskCanvas) {
      // Create a temporary canvas to apply red tint to the mask
      const tempCanvas = document.createElement('canvas')
      const tempCtx = tempCanvas.getContext('2d')
      tempCanvas.width = this.maskCanvas.width
      tempCanvas.height = this.maskCanvas.height
      
      // Draw the mask in red
      tempCtx.globalCompositeOperation = 'source-over'
      tempCtx.fillStyle = 'rgba(255, 100, 100, 0.5)'  // Semi-transparent red
      tempCtx.fillRect(0, 0, tempCanvas.width, tempCanvas.height)
      
      // Use the original mask as an alpha mask
      tempCtx.globalCompositeOperation = 'destination-in'
      tempCtx.drawImage(this.maskCanvas, 0, 0)
      
      // Draw the red-tinted mask overlay
      this.ctx.globalAlpha = 1.0
      this.ctx.drawImage(tempCanvas, 0, 0)
    }
  }

  clearMask() {
    // Clear the mask canvas completely
    if (this.maskCtx) {
      this.maskCtx.clearRect(0, 0, this.maskCanvas.width, this.maskCanvas.height)
    }
    
    // Redraw the display canvas
    this.redrawCanvas()
    this.updateMaskData()
  }

  clearMaskAction() {
    this.clearMask()
  }

  setDrawMode() {
    this.modeValue = "draw"
    this.updateUI()
  }

  setEraseMode() {
    this.modeValue = "erase"
    this.updateUI()
  }

  updateUI() {
    // Update button states
    const drawBtn = this.element.querySelector('[data-action="click->mask-painter#setDrawMode"]')
    const eraseBtn = this.element.querySelector('[data-action="click->mask-painter#setEraseMode"]')
    
    if (drawBtn && eraseBtn) {
      if (this.modeValue === "draw") {
        drawBtn.classList.add('bg-blue-600', 'text-white')
        drawBtn.classList.remove('bg-gray-200', 'text-gray-700')
        eraseBtn.classList.remove('bg-blue-600', 'text-white')
        eraseBtn.classList.add('bg-gray-200', 'text-gray-700')
      } else {
        eraseBtn.classList.add('bg-blue-600', 'text-white')
        eraseBtn.classList.remove('bg-gray-200', 'text-gray-700')
        drawBtn.classList.remove('bg-blue-600', 'text-white')
        drawBtn.classList.add('bg-gray-200', 'text-gray-700')
      }
    }

    // Update cursor
    this.canvas.style.cursor = this.modeValue === "draw" ? 'crosshair' : 'not-allowed'
  }

  setBrushSize(event) {
    this.brushSizeValue = parseInt(event.target.value)
  }

  getMousePos(event) {
    const rect = this.canvas.getBoundingClientRect()
    
    // Calculate scale factors for the actual canvas size vs display size
    const scaleX = this.canvas.width / rect.width
    const scaleY = this.canvas.height / rect.height
    
    return {
      x: (event.clientX - rect.left) * scaleX,
      y: (event.clientY - rect.top) * scaleY
    }
  }

  getTouchPos(event) {
    const rect = this.canvas.getBoundingClientRect()
    
    // Calculate scale factors for the actual canvas size vs display size
    const scaleX = this.canvas.width / rect.width
    const scaleY = this.canvas.height / rect.height
    
    return {
      x: (event.touches[0].clientX - rect.left) * scaleX,
      y: (event.touches[0].clientY - rect.top) * scaleY
    }
  }

  startDrawing(event) {
    this.isDrawing = true
    const pos = this.getMousePos(event)
    this.lastX = pos.x
    this.lastY = pos.y
  }

  draw(event) {
    if (!this.isDrawing) return
    
    event.preventDefault()
    const pos = this.getMousePos(event)
    
    // Draw on the mask canvas
    if (!this.maskCtx) return
    
    this.maskCtx.lineWidth = this.brushSizeValue
    this.maskCtx.lineCap = 'round'
    this.maskCtx.lineJoin = 'round'
    
    if (this.modeValue === "draw") {
      // Draw white for areas to edit
      this.maskCtx.globalCompositeOperation = 'source-over'
      this.maskCtx.strokeStyle = 'rgba(255, 255, 255, 1.0)'
    } else {
      // Erase (transparent)
      this.maskCtx.globalCompositeOperation = 'destination-out'
    }
    
    this.maskCtx.beginPath()
    this.maskCtx.moveTo(this.lastX, this.lastY)
    this.maskCtx.lineTo(pos.x, pos.y)
    this.maskCtx.stroke()
    
    this.lastX = pos.x
    this.lastY = pos.y
    
    // Redraw the display canvas with updated mask
    this.redrawCanvas()
    this.updateMaskData()
  }

  stopDrawing() {
    this.isDrawing = false
  }

  handleTouch(event) {
    event.preventDefault()
    const touch = event.touches[0]
    const mouseEvent = new MouseEvent(event.type === 'touchstart' ? 'mousedown' : 'mousemove', {
      clientX: touch.clientX,
      clientY: touch.clientY
    })
    
    if (event.type === 'touchstart') {
      this.startDrawing(mouseEvent)
    } else if (event.type === 'touchmove') {
      this.draw(mouseEvent)
    }
  }

  updateMaskData() {
    // Convert mask canvas to base64 data URL (PNG format for transparency)
    if (!this.maskCanvas) return
    
    const maskDataUrl = this.maskCanvas.toDataURL('image/png')
    
    // Extract just the base64 data (remove "data:image/png;base64," prefix)
    const base64Data = maskDataUrl.split(',')[1]
    
    // Update the hidden form field
    if (this.hasMaskDataTarget) {
      this.maskDataTarget.value = base64Data
    }
  }

  // Method to be called when an image checkbox is selected
  onImageSelected(event) {
    const checkbox = event.target
    const imageContainer = checkbox.closest('.flex.items-center')
    const imgElement = imageContainer.querySelector('img')
    
    if (checkbox.checked && imgElement) {
      // Clear other checkboxes if this is the first selection (only show one image at a time in mask)
      const allCheckboxes = this.element.querySelectorAll('input[type="checkbox"]')
      const selectedCheckboxes = Array.from(allCheckboxes).filter(cb => cb.checked)
      
      // Load the image to canvas for mask editing (use the first selected image)
      if (selectedCheckboxes.length >= 1) {
        this.loadImageToCanvas(imgElement)
      }
    } else if (!checkbox.checked) {
      // If no images are selected, clear the canvas
      const allCheckboxes = this.element.querySelectorAll('input[type="checkbox"]')
      const selectedCheckboxes = Array.from(allCheckboxes).filter(cb => cb.checked)
      
      if (selectedCheckboxes.length === 0) {
        // Reset canvas to default size and show placeholder
        this.canvas.width = 400
        this.canvas.height = 300
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height)
        this.ctx.fillStyle = '#9ca3af'
        this.ctx.font = '16px system-ui'
        this.ctx.textAlign = 'center'
        this.ctx.fillText('Select an image above to start drawing', this.canvas.width / 2, this.canvas.height / 2)
        
        if (this.maskCtx) {
          this.maskCtx.clearRect(0, 0, this.maskCanvas.width, this.maskCanvas.height)
        }
        this.backgroundImage = null
        this.updateMaskData()
      }
    }
  }
}
