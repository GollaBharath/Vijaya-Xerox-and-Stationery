-- Seed initial support information
INSERT INTO support_info (
  id,
  shop_name,
  shop_phone,
  shop_email,
  shop_whatsapp,
  shop_address,
  developer_name,
  developer_email,
  developer_whatsapp,
  working_hours,
  website_url,
  created_at,
  updated_at
) VALUES (
  'default_support_info',
  'Vijaya Xerox & Stationery',
  '+91 1234567890',
  'vijayaxerox@example.com',
  '+911234567890',
  '123 Main Street, City Name, State - 123456',
  'Developer Team',
  'developer@example.com',
  '+919876543210',
  'Monday to Saturday: 9:00 AM - 7:00 PM
Sunday: Closed',
  'https://vijayaxerox.com',
  NOW(),
  NOW()
) ON CONFLICT (id) DO NOTHING;
