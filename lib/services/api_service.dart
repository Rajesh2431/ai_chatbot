import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterAPI {
  static const _apiKey =
      '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';
  static const _url = 'https://openrouter.ai/api/v1/chat/completions';

  static Future<String> getResponse(String prompt) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'http://thirdvizion.com',
        'X-Title': 'Flutter AI Bot',
      },
      body: jsonEncode({
        //'model': 'openrouter/cypher-alpha:free',
        'model': 'mistralai/mistral-small-3.1-24b-instruct:free',
        // 'model':
        //     'cognitivecomputations/dolphin-mistral-24b-venice-edition:free',
        //'model': 'cognitivecomputations/dolphin3.0-mistral-24b:free',
        //'model': 'google/gemini-2.0-flash-exp:free',
        //'model': 'deepseek/deepseek-chat-v3-0324:free',
        'messages': [
          {
            'role': 'user',
            'content': '''
                        Your name is Shiro and You are a licensed mental health counselor.

                        Your primary responsibilities are:
                        - Listen empathetically and respond with kindness.
                        - Provide support for stress, anxiety, depression, trauma, relationships, and emotional well-being.
                        - Use a calm, nurturing, and non-judgmental tone.
                        - Avoid giving medical diagnoses, but encourage seeking professional care when necessary.
                        - Avoid unrelated topics (e.g. tech, math, politics, entertainment).
                        - You always suggest activities for user to reduce their stress
                        - Always give short and understandable replys
                        - Add some emojis to your replies
                        -
                        ''',
          },
          {'role': 'user', 'content': prompt},
        ],
      }),
    );

    final data = jsonDecode(response.body);
    return data['choices'][0]['message']['content'].trim();
  }
}
