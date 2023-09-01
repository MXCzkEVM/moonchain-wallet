import openai
import json
import time
import argparse

# Replace this with your actual API key
openai.api_key = "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"

# Function to translate text using GPT-4
def translate(text, target_language):
    messages = [
            {"role": "system", "content": "You are an experienced cryptocurrency translator who translates without error"},
            {"role": "user", "content": f"Translate the following English text to {target_language}: {text}"},
        ]
    response = openai.ChatCompletion.create(
                model="gpt-4",
                messages=messages,
                temperature=0.1,
                max_tokens=1024,  # here is the amount of the text in answers
                top_p=0.1,
                frequency_penalty=0.3,
                presence_penalty=0.6,
    )
    return response["choices"][0]["message"]["content"].strip()

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
    with open('en.json', 'r') as file:
        en_data = json.load(file)

    # Loop through each language in the dictionary
    for lang_code, lang_name in language_dict.items():
        # Load the existing language file or create an empty dictionary if it doesn't exist
        try:
            with open(f'{lang_code}.json', 'r') as file:
                lang_data = json.load(file)
        except FileNotFoundError:
            lang_data = {}

        # Find keys that are present in en.json but not in the current language file
        new_entries = {key: en_data[key] for key in en_data if key not in lang_data}

        # Translate the new entries
        for key, value in new_entries.items():
            lang_data[key] = translate(value, lang_name)
            time.sleep(6)  # Pause for a bit between each translation request

        # Write the updated JSON to the language file
        with open(f'{lang_code}.json', 'w') as file:
            json.dump(lang_data, file, ensure_ascii=False, indent=4)

        print(f"Translation to {lang_name} complete. Check the '{lang_code}.json' file.")

if __name__ == '__main__':
    main()
