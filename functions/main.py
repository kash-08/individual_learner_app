import functions_framework
import firebase_admin
from firebase_admin import firestore, credentials
import google.generativeai as genai
import json
from flask import jsonify, request

# Initialize Firebase
cred = credentials.ApplicationDefault()
firebase_admin.initialize_app(cred)
db = firestore.client()

# Initialize Gemini AI
genai.configure(api_key="AIzaSyBTAT5Ipn4JUrNT_PW_t6DD4OGJfpVUYv0")  # Get from: https://aistudio.google.com/

@functions_framework.http
def ai_assistant(request):
    # Set CORS headers
    headers = {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
    }

    if request.method == 'OPTIONS':
        return ('', 204, headers)

    try:
        data = request.get_json()
        message = data.get('message')
        user_id = data.get('userId')
        conversation_id = data.get('conversationId')

        if not message:
            return (jsonify({'error': 'Message is required'}), 400, headers)

        # Get AI response from Gemini
        model = genai.GenerativeModel('gemini-1.0-pro')  # ← CHANGED THIS LINE
        response = model.generate_content(f"""
        You are an AI Learning Assistant. Help students with their studies.

        Student's message: {message}

        Respond helpfully and educationally.
        """)

        ai_response = response.text

        # Save to Firestore if user ID provided
        if user_id:
            conv_ref = db.collection('ai_conversations').document(conversation_id or '')
            if not conversation_id:
                conv_ref = db.collection('ai_conversations').document()
                conv_ref.set({
                    'userId': user_id,
                    'title': message[:30] + ('...' if len(message) > 30 else ''),
                    'createdAt': firestore.SERVER_TIMESTAMP,
                    'updatedAt': firestore.SERVER_TIMESTAMP,
                })

            # Save messages
            conv_ref.collection('messages').add({
                'text': message,
                'senderId': user_id,
                'senderName': 'You',
                'timestamp': firestore.SERVER_TIMESTAMP,
                'isAI': False,
            })

            conv_ref.collection('messages').add({
                'text': ai_response,
                'senderId': 'ai',
                'senderName': 'AI Assistant',
                'timestamp': firestore.SERVER_TIMESTAMP,
                'isAI': True,
            })

            conv_ref.update({'updatedAt': firestore.SERVER_TIMESTAMP})

        return (jsonify({
            'response': ai_response,
            'conversationId': conv_ref.id if 'conv_ref' in locals() else None,
            'timestamp': firestore.SERVER_TIMESTAMP,
        }), 200, headers)

    except Exception as e:
        return (jsonify({'error': str(e)}), 500, headers)

@functions_framework.http
def health_check(request):
    return (jsonify({'status': 'healthy', 'service': 'AI Assistant'}), 200)