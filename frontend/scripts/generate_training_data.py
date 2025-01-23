from PIL import Image, ImageDraw, ImageFont
import random
import os
import arabic_reshaper
from bidi.algorithm import get_display

def generate_synthetic_id_card():
    # Create base image
    width = 800
    height = 500
    image = Image.new('RGB', (width, height), 'white')
    draw = ImageDraw.Draw(image)
    
    # Load fonts
    french_font = ImageFont.truetype('arial.ttf', 32)
    arabic_font = ImageFont.truetype('arial.ttf', 32)  # Use appropriate Arabic font
    
    # Common text patterns on Moroccan IDs
    french_texts = [
        "ROYAUME DU MAROC",
        "CARTE NATIONALE D'IDENTITE",
        "Date de naissance:",
        "Lieu de naissance:",
        "CIN:"
    ]
    
    arabic_texts = [
        "المملكة المغربية",
        "البطاقة الوطنية للتعريف",
        "تاريخ الازدياد",
        "مكان الازدياد"
    ]
    
    # Generate random data
    names = ["MOHAMMED ALAMI", "FATIMA BENNANI", "AHMED TAZI"]
    cities = ["CASABLANCA", "RABAT", "FES", "TANGER"]
    
    # Add text to image
    y_offset = 50
    for text in french_texts:
        draw.text((50, y_offset), text, fill='black', font=french_font)
        y_offset += 40
    
    # Add Arabic text (right-aligned)
    y_offset = 50
    for text in arabic_texts:
        reshaped_text = arabic_reshaper.reshape(text)
        bidi_text = get_display(reshaped_text)
        draw.text((width-50, y_offset), bidi_text, fill='black', font=arabic_font, anchor="ra")
        y_offset += 40
    
    # Add random data
    draw.text((200, 300), random.choice(names), fill='black', font=french_font)
    draw.text((200, 340), random.choice(cities), fill='black', font=french_font)
    draw.text((200, 380), f"{random.choice('ABCDEFGHIJKLMNOPQRSTUVWXYZ')}{random.randint(100000, 999999)}", fill='black', font=french_font)
    
    return image

def generate_dataset(num_images=100, output_dir='training_data'):
    os.makedirs(output_dir, exist_ok=True)
    
    for i in range(num_images):
        image = generate_synthetic_id_card()
        # Add random noise, rotation, blur etc. for more realistic data
        image.save(f"{output_dir}/synthetic_id_{i}.png")
        
if __name__ == "__main__":
    generate_dataset() 