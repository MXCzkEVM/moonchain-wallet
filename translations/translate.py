import google.generativeai as genai
import json
import time
import argparse
import os

genai.configure(api_key=os.environ.get('GEMINI_API_KEY'))

# Function to translate text using Gemini
def translate(text, target_language):
    model = genai.GenerativeModel("gemini-1.5-flash")  
    try:
        response = model.generate_content(
            f"""You are a translator API. Your task is to translate the following text.

CRITICAL INSTRUCTIONS:
1. Translate the entire text as is, without adding or removing any characters or placeholders.
2. Do NOT add any curly braces {{ }} that are not in the original text.
3. Provide ONLY the translated text as your response.
4. Do NOT include any markdown formatting, quotation marks, backticks, or extra newline characters in your response.
5. Preserve the exact structure and formatting of the original text.

Original text (in English):
{text}

Translate the above text to {target_language}. Remember, provide ONLY the direct translation without any modifications to the structure or added characters."""
        )
        print(response)
        if response.parts:
            return response.parts[0].text.strip()
        else:
            raise ValueError("No translation generated")
    except Exception as e:
        print(f"Translation error for '{text}': {str(e)}")
        return text  # Return original text if translation fails

def main():
    language_dict = {
        "de": "German",
        "es": "Español",
        "fr": "Français",
        "it": "Italiano",
        "ko": "Korean",
        "nl": "Dutch",
        "ro": "Romanian",
        "tr": "Turkish",
        "zh_CN": "Chinese Simplified",
        "zh_TW": "Chinese Traditional",
        "id": "Indonesian",
        "pt": "Portuguese",
        "vi": "Vietnamese",
        "ja": "Japanese",
        "ru": "Russian"
    }
    # Read the input JSON file
    with open('../assets/flutter_i18n/en.json', 'r') as file:
        en_data = json.load(file)

    # Loop through each language in the dictionary
    for lang_code, lang_name in language_dict.items():
        # Load the existing language file or create an empty dictionary if it doesn't exist
        try:
            with open(f'../assets/flutter_i18n/{lang_code}.json', 'r') as file:
                lang_data = json.load(file)
        except FileNotFoundError:
            lang_data = {}

        # Find keys that are present in en.json but not in the current language file
        new_entries = {key: en_data[key] for key in en_data if key not in lang_data}

        # Translate the new entries
        for key, value in new_entries.items():
            lang_data[key] = translate(value, lang_name)
            time.sleep(10)  # Pause for a bit between each translation r
        with open(f'../assets/flutter_i18n/{lang_code}.json', 'w') as file:
            json.dump(lang_data, file, ensure_ascii=False, indent=4)

        print(f"Translation to {lang_name} complete. Check the '{lang_code}.json' file.")

if __name__ == '__main__':
    main()

