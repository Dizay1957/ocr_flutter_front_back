from PIL import Image, ImageDraw, ImageFont
import os
import random
import arabic_reshaper
from bidi.algorithm import get_display

def generate_letter_samples():
    # Create output directory
    output_dir = 'training_data/letters'
    os.makedirs(output_dir, exist_ok=True)

    # Font configurations using system fonts
    fonts = [
        # For French text and numbers
        ('arial.ttf', 32),
        ('times.ttf', 32),
        # For Arabic text
        ('arial.ttf', 32),  # Arial supports Arabic
    ]

    # Characters to generate
    characters = {
        'french_letters': 'ABCDEFGHIJKLMNOPQRSTUVWXYZ',
        'french_special': 'éèêëîïôöûüçÉÈÊËÎÏÔÖÛÜÇ',
        'numbers': '0123456789',
        'arabic_letters': 'ابتثجحخدذرزسشصضطظعغفقكلمنهوي',
        'arabic_numbers': '٠١٢٣٤٥٦٧٨٩',
        'symbols': '-/.'
    }

    # Common words in Moroccan IDs
    common_words = {
        'french': [
            'ROYAUME DU MAROC',
            'CARTE NATIONALE',
            "D'IDENTITE",
            'DATE DE NAISSANCE',
            'LIEU DE NAISSANCE'
        ],
        'arabic': [
            'المملكة المغربية',
            'البطاقة الوطنية',
            'للتعريف',
            'تاريخ الازدياد',
            'مكان الازدياد'
        ]
    }

    # Background colors similar to Moroccan ID cards
    backgrounds = ['white', '#f5f5f5', '#efefef', '#e8e8e8']

    for font_name, font_size in fonts:
        try:
            font = ImageFont.truetype(font_name, font_size)
            is_arabic_font = font_name == 'arial.ttf'  # Use Arial for Arabic
            
            # Generate single characters
            for char_type, chars in characters.items():
                if (is_arabic_font and 'arabic' in char_type) or (not is_arabic_font and 'arabic' not in char_type):
                    for char in chars:
                        for i in range(20):
                            img = Image.new('RGB', (64, 64), random.choice(backgrounds))
                            draw = ImageDraw.Draw(img)

                            # Add variations
                            rotation = random.uniform(-3, 3)
                            position = (32 + random.uniform(-2, 2), 32 + random.uniform(-2, 2))

                            # Handle Arabic text direction
                            text = char
                            if is_arabic_font:
                                text = arabic_reshaper.reshape(char)
                                text = get_display(text)

                            draw.text(
                                position, 
                                text, 
                                fill='black', 
                                font=font, 
                                anchor="mm",
                                rotation=rotation
                            )

                            filename = f"{char_type}_{ord(char)}_{i}.png"
                            img.save(os.path.join(output_dir, filename))

            # Generate common words
            lang = 'arabic' if is_arabic_font else 'french'
            for word in common_words[lang]:
                for i in range(10):
                    # Larger image for words
                    img = Image.new('RGB', (300, 64), random.choice(backgrounds))
                    draw = ImageDraw.Draw(img)

                    text = word
                    if is_arabic_font:
                        text = arabic_reshaper.reshape(word)
                        text = get_display(text)

                    draw.text(
                        (150, 32), 
                        text, 
                        fill='black', 
                        font=font, 
                        anchor="mm"
                    )

                    filename = f"word_{lang}_{i}_{hash(word)}.png"
                    img.save(os.path.join(output_dir, filename))

        except Exception as e:
            print(f"Error with font {font_name}: {e}")

if __name__ == "__main__":
    generate_letter_samples() 