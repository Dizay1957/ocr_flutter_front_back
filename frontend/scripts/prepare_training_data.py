import os
from PIL import Image
import pytesseract

def prepare_training_data():
    training_dir = 'training_data'
    output_dir = 'C:/Program Files/Tesseract-OCR/tessdata'
    
    # Create box files for training
    for image_file in os.listdir(training_dir):
        if image_file.endswith('.png'):
            image_path = os.path.join(training_dir, image_file)
            # Generate box file
            pytesseract.pytesseract.run_tesseract(
                image_path,
                image_file[:-4],
                extension='box',
                config='makebox'
            )

if __name__ == "__main__":
    prepare_training_data() 