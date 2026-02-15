
import axios from 'axios';
import fs from 'fs';
import path from 'path';
import { PDFDocument, PageSizes } from 'pdf-lib';
import FormData from 'form-data';

const API_URL = 'http://localhost:3000/api/v1';
const ADMIN_EMAIL = 'vijaya@admin.com';
const ADMIN_PASSWORD = 'admin14321';

async function main() {
    console.log('🚀 Starting Verification: PDF Preview Generation');

    // 1. Login
    console.log('\n🔑 Logging in as Admin...');
    let token;
    try {
        const loginRes = await axios.post(`${API_URL}/auth/login`, {
            email: ADMIN_EMAIL,
            password: ADMIN_PASSWORD,
        });
        console.log('Login Response Data:', JSON.stringify(loginRes.data, null, 2));
        token = loginRes.data.data?.tokens?.accessToken || loginRes.data.data?.accessToken;
        console.log('✅ Login successful');
    } catch (error: any) {
        console.error('❌ Login failed:', error.message);
        if (error.response) {
            console.error('Status:', error.response.status);
            console.error('Data:', error.response.data);
        } else if (error.request) {
            console.error('No response received (Network Error?)');
        }
        process.exit(1);
    }

    // 2. Create Dummy Product
    console.log('\n📦 Creating Dummy Product...');
    let productId;
    try {
        const productRes = await axios.post(
            `${API_URL}/catalog/products`,
            {
                title: 'Test PDF Product',
                basePrice: 100,
                subjectId: 'dummy-subject-id', // We might need a real subject ID.
                // Let's list subjects first or create one if needed, but let's try to fetch one.
            },
            { headers: { Authorization: `Bearer ${token}` } }
        );
        productId = productRes.data.data.id;
        console.log(`✅ Product created: ${productId}`);
    } catch (error: any) {
        // If subject fails, we need to fetch a subject
        const errorMsg = error.response?.data?.error || error.response?.data?.message || JSON.stringify(error.response?.data);

        if (typeof errorMsg === 'string' && errorMsg.includes('Foreign key constraint failed')) {
            console.log('⚠️ Failed to create product (Subject ID issue). Fetching subjects...');
            // Fetch subjects
            try {
                const subjectsRes = await axios.get(`${API_URL}/catalog/subjects?limit=1`);
                const subjectId = subjectsRes.data.data.subjects[0]?.id;
                if (!subjectId) {
                    console.error('❌ No subjects found. Cannot create product.');
                    process.exit(1);
                }
                console.log(`Using Subject ID: ${subjectId}`);
                const productResRetry = await axios.post(
                    `${API_URL}/catalog/products`,
                    {
                        title: 'Test PDF Product Retry',
                        basePrice: 100,
                        subjectId: subjectId,
                    },
                    { headers: { Authorization: `Bearer ${token}` } }
                );
                productId = productResRetry.data.data.id;
                console.log(`✅ Product created (Retry): ${productId}`);
            } catch (e: any) {
                console.error('❌ Failed to create product even after retry:', e.response?.data || e.message);
                console.error(e); // Log full error
                process.exit(1);
            }
        } else {
            console.error('❌ Failed to create product:', error.response?.data || error.message);
            console.error(error); // Log full error
            process.exit(1);
        }
    }

    // 3. Create Dummy PDF
    console.log('\n📄 Generating Dummy PDF...');
    const pdfDoc = await PDFDocument.create();
    const page = pdfDoc.addPage(PageSizes.A4);
    page.drawText('This is a test PDF for preview generation.', { x: 50, y: 700, size: 30 });
    const pdfBytes = await pdfDoc.save();
    const pdfPath = path.join(__dirname, 'test.pdf');
    fs.writeFileSync(pdfPath, pdfBytes);
    console.log(`✅ PDF generated at ${pdfPath}`);

    // 4. Upload PDF
    console.log('\n⬆️ Uploading PDF...');
    try {
        const form = new FormData();
        form.append('file', fs.createReadStream(pdfPath));
        form.append('productId', productId);

        const uploadRes = await axios.post(
            `${API_URL}/catalog/products/upload-pdf`,
            form,
            {
                headers: {
                    Authorization: `Bearer ${token}`,
                    ...form.getHeaders(),
                },
            }
        );

        console.log('Response:', uploadRes.data);

        if (uploadRes.data.previewUrl) {
            console.log(`✅ Preview generated! URL: ${uploadRes.data.previewUrl}`);
            // Verify file exists (optional, as URL presence implies it)
        } else {
            console.error('❌ Preview URL is missing in response!');
            process.exit(1);
        }

    } catch (error: any) {
        console.error('❌ Upload failed:', error.response?.data || error.message);
        process.exit(1);
    }

    // 5. Cleanup
    console.log('\n🧹 Cleaning up...');
    try {
        await axios.delete(`${API_URL}/catalog/products/${productId}`, {
            headers: { Authorization: `Bearer ${token}` }
        });
        fs.unlinkSync(pdfPath);
        console.log('✅ Cleanup successful');
    } catch (e) {
        console.warn('⚠️ Cleanup failed (non-critical)');
    }
}

main();
