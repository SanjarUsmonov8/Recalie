from django.test import TestCase
from django.urls import reverse

class SubjectApiTests(TestCase):
    def test_subject_list_is_public(self):
        response = self.client.get(reverse('subject-list'))
        self.assertEqual(response.status_code, 200)
        self.assertEqual(len(response.json()), 10)
        self.assertEqual(response.json()[0]['slug'], 'english')

    def test_subject_detail_contains_parts_and_review_blocks(self):
        response = self.client.get(reverse('subject-detail', args=['physics']))
        self.assertEqual(response.status_code, 200)
        block = response.json()['parts'][0]['review_blocks'][0]
        self.assertEqual(block['title'], 'Motion and graphs')
        self.assertEqual(len(block['key_points']), 4)
        self.assertEqual(block['estimated_minutes'], 50)
