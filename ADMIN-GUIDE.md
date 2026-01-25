# 📊 Admin Guide - Managing Your Scholarship Portal

## 🔐 Admin Access
- **URL**: `https://your-vercel-url.vercel.app/admin`
- **Email**: `admin@drkabiruscholarship.com`
- **Password**: `DrKabiru2025!Admin`

## 📋 Daily Management Tasks

### **1. Review New Applications**
- Login to admin dashboard
- Check "Pending" applications
- Review application details and documents
- Update status to "Under Review"

### **2. Application Status Management**
Available statuses:
- **Pending**: New applications (default)
- **Under Review**: Being evaluated
- **Approved**: Scholarship awarded
- **Rejected**: Application declined

### **3. Search and Filter Applications**
- **Search by**: Name, email, university, community
- **Filter by**: Status, submission date
- **Sort by**: Date, name, CGPA, community

### **4. Document Review**
For each application, you can view:
- Academic transcript
- Application letter
- Nomination letter
- Supporting documents

### **5. Export Data**
- **Excel Export**: Full application data with all fields
- **CSV Export**: Simplified format for analysis
- **Use for**: Reports, statistics, record keeping

## 📊 Application Statistics

The dashboard shows:
- **Total Applications**: All submitted applications
- **Pending**: Awaiting review
- **Approved**: Scholarships awarded
- **Rejected**: Declined applications

## 🔄 Regular Maintenance

### **Weekly Tasks:**
- Review and update application statuses
- Export data for backup
- Check for any technical issues

### **Monthly Tasks:**
- Generate reports for stakeholders
- Review application trends
- Update community list if needed

## 🚨 Troubleshooting

### **If admin login doesn't work:**
1. Check email/password spelling
2. Clear browser cache
3. Try incognito/private browsing mode
4. Check Supabase user_roles table

### **If applications aren't showing:**
1. Check Supabase database connection
2. Verify RLS policies are active
3. Check browser console for errors

### **If file uploads fail:**
1. Check Supabase Storage configuration
2. Verify file size limits
3. Check internet connection

## 📞 Support Information

### **Technical Issues:**
- Check Vercel deployment logs
- Review Supabase project logs
- Check browser developer console

### **Database Access:**
- Supabase Dashboard: https://supabase.com/dashboard
- Project ID: Your project ID
- Direct database access via SQL Editor

## 🔒 Security Best Practices

1. **Change default admin password** after first login
2. **Regular backups** of application data
3. **Monitor admin access logs**
4. **Keep Supabase project secure**

## 📈 Scaling Your Portal

As applications increase:
- **Monitor database usage** in Supabase
- **Consider upgrading** Supabase plan if needed
- **Regular data exports** for backup
- **Performance monitoring** via Vercel analytics