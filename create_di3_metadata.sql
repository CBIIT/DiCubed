delete from di3metadata.di3;

insert into di3metadata.di3(c_hlevel, c_fullname, c_name, c_visualattributes, c_metadataxml, c_dimcode, c_tooltip,
  c_basecode, c_comment,
c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, m_applied_path,
update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, c_synonym_cd, c_path, c_symbol, c_totalnum
)  

with consts as (
select cast('concept_cd' as varchar(50)) as c_facttablecolumn,
       cast('concept_dimension' as varchar(50)) as c_tablename, 
       cast('concept_path' as varchar(50)) as c_columnname,
       cast('T' as varchar(50)) as c_columndatatype,
       cast('LIKE' as varchar(50)) as c_operator,
       cast('@' as varchar(700)) as m_applied_path,
       current_timestamp as update_date,
       current_timestamp as download_date,
       current_timestamp as import_date,
       cast('DI3' as varchar(50)) as sourcesystem_cd,
       cast(NULL as varchar(50)) as valuetype_cd,
       cast('N' as char(1)) as c_synonym_cd, 
       cast(NULL as varchar(700)) as c_path,
       cast(NULL as varchar(50)) as c_symbol,
       cast(NULL as integer) as c_totalnum
)
,
level_1 as (
select 1 as c_hlevel,
       cast($$\Demographics\$$  as varchar(700)) as c_fullname, 
       cast('Demographics' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\$$ as varchar(700)) as c_dimcode,
       cast('Demographics' as varchar(900)) as c_tooltip,
       cast('NCIt:C16495' as varchar(50)) as c_basecode,
       cast('The statistical characterization of human populations or segments of human populations (e.g., characterization by age, sex, race, or income).' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Clinical Course of Disease\$$  as varchar(700)) as c_fullname, 
       cast('Clinincal Course of Disease' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Clinical Course of Disease\$$ as varchar(700)) as c_dimcode,
       cast('A description of the series of events, including signs and symptoms, that define the course of a chronic disease over time.' as varchar(900)) as c_tooltip,
       cast('NCIt:C35461' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C35461' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Primary Diagnosis\$$  as varchar(700)) as c_fullname, 
       cast('Primary Diagnosis' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\$$ as varchar(700)) as c_dimcode,
       cast('The investigation, analysis and recognition of the presence and nature of disease, condition, or injury from expressed signs and symptoms; also, the scientific determination of any kind; the concise results of such an investigation.' as varchar(900)) as c_tooltip,
       cast('NCIt:C15220' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C15220' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Data Set\$$  as varchar(700)) as c_fullname, 
       cast('Data Set' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Data Set\$$ as varchar(700)) as c_dimcode,
       cast('Data Set' as varchar(900)) as c_tooltip,
       cast('NCIt:C47824' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C47824' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Anatomic Site\$$  as varchar(700)) as c_fullname, 
       cast('Anatomic Site' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Anatomic Site\$$ as varchar(700)) as c_dimcode,
       cast('Named locations of or within the body.' as varchar(900)) as c_tooltip,
       cast('NCIt:C13717' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C137171' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Survival Status\$$  as varchar(700)) as c_fullname, 
       cast('Vital Status' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Survival Status\$$ as varchar(700)) as c_dimcode,
       cast('The state or condition of being living or deceased; also includes the case where the vital status is unknown.' as varchar(900)) as c_tooltip,
       cast('NCIt:C25717' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C25717' as text) as c_comment
union
select 1 as c_hlevel,
       cast($$\Laterality\$$  as varchar(700)) as c_fullname, 
       cast('Laterality' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Laterality\$$ as varchar(700)) as c_dimcode,
       cast('Laterality' as varchar(900)) as c_tooltip,
       cast('NCIt:C25185' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C25185' as text) as c_comment
)
,
course_of_disease as (
select 2 as c_hlevel,
       cast($$\Clinical Course of Disease\C38155\$$  as varchar(700)) as c_fullname, 
       cast('Recurrent Disease' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Clinical Course of Disease\C38155\$$ as varchar(700)) as c_dimcode,
       cast('The return of a disease after a period of remission.' as varchar(900)) as c_tooltip,
       cast('NCIt:C38155' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C38155' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Clinical Course of Disease\C40413\$$  as varchar(700)) as c_fullname, 
       cast('No Evidence of Disease' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Clinical Course of Disease\C40413\$$ as varchar(700)) as c_dimcode,
       cast('An absence of detectable disease.' as varchar(900)) as c_tooltip,
       cast('NCIt:C40413' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C40413' as text) as c_comment
)
,
survival as (
select 2 as c_hlevel,
       cast($$\Survival Status\C37987\$$  as varchar(700)) as c_fullname, 
       cast('Alive' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Survival Status\C37987\$$ as varchar(700)) as c_dimcode,
       cast('Living; showing characteristics of life.' as varchar(900)) as c_tooltip,
       cast('NCIt:C37987' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C37987' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Survival Status\C28554\$$  as varchar(700)) as c_fullname, 
       cast('Dead' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Survival Status\C28554$$ as varchar(700)) as c_dimcode,
       cast('The absence of life or state of being dead. (NCI)' as varchar(900)) as c_tooltip,
       cast('NCIt:C28554' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C28554' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Survival Status\C48227\$$  as varchar(700)) as c_fullname, 
       cast('Lost to Follow-up' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Survival Status\C48227\$$ as varchar(700)) as c_dimcode,
       cast('The loss or lack of continuation of a subject to follow-up.' as varchar(900)) as c_tooltip,
       cast('NCIt:C48227' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C48227' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Survival Status\C25717+C17998\$$  as varchar(700)) as c_fullname, 
       cast('Unknown' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Survival Status\C25717+C17998\$$ as varchar(700)) as c_dimcode,
       cast('Unknown vital status' as varchar(900)) as c_tooltip,
       cast('NCIt:C25717+NCIt:C17998' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C17998' as text) as c_comment
),
datasets as (
select 2 as c_hlevel,
       cast($$\Data Set\I-Spy1\$$  as varchar(700)) as c_fullname, 
       cast('I-Spy1' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Data Set\I-Spy1\$$ as varchar(700)) as c_dimcode,
       cast('I-Spy1' as varchar(900)) as c_tooltip,
       cast('NCIt:C47824|I-Spy1' as varchar(50)) as c_basecode,
       cast(NULL as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Data Set\Breast Diagnosis\$$  as varchar(700)) as c_fullname, 
       cast('Breast Diagnosis' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Data Set\Breast Diagnosis\$$ as varchar(700)) as c_dimcode,
       cast('Breast Diagnosis' as varchar(900)) as c_tooltip,
       cast('NCIt:C47824|Breast Diagnosis' as varchar(50)) as c_basecode,
       cast(NULL as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Data Set\Breast-MRI-NACT-Pilot\$$  as varchar(700)) as c_fullname, 
       cast('Breast-MRI-NACT-Pilot' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Data Set\Breast-MRI-NACT-Pilot\$$ as varchar(700)) as c_dimcode,
       cast('Breast-MRI-NACT-Pilot: This collection contains longitudinal DCE MRI studies of 64 patients undergoing neoadjuvant chemotherapy (NACT) for invasive breast cancer. ' as varchar(900)) as c_tooltip,
       cast('NCIt:C47824|Breast-MRI-NACT-Pilot' as varchar(50)) as c_basecode,
       cast(NULL as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Data Set\TCGA-BRCA\$$  as varchar(700)) as c_fullname, 
       cast('TCGA-BRCA' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Data Set\TCGA-BRCA\$$ as varchar(700)) as c_dimcode,
       cast($$The Cancer Genome Atlas Breast Invasive Carcinoma (TCGA-BRCA) data collection is part of a larger effort to build a research community focused on connecting cancer phenotypes to genotypes by providing clinical images matched to subjects from The Cancer Genome Atlas (TCGA). Clinical, genetic, and pathological data resides in the Genomic Data Commons (GDC) Data Portal while the radiological data is stored on The Cancer Imaging Archive (TCIA). $$  as varchar(900)) as c_tooltip,
       cast('NCIt:C47824|TCGA-BRCA' as varchar(50)) as c_basecode,
       cast(NULL as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Data Set\Ivy-Gap\$$  as varchar(700)) as c_fullname, 
       cast('Ivy-Gap' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Data Set\Ivy-Gap\$$ as varchar(700)) as c_dimcode,
       cast($$This data collection consists of MRI/CT scan data for brain tumor patients that form the cohort for the resource Ivy Glioblastoma Atlast Project (Ivy GAP). There are 390 studies for 39 patients that include pre-surgery, post-surgery and follow up scans. The Ivy Glioblastoma Atlas Project (Ivy GAP) is a collaborative partnership between the Ben and Catherine Ivy Foundation, which generously provided the financial support, the Allen Institute for Brain Science, and the Ben and Catherine Ivy Center for Advanced Brain Tumor Treatment. The goal of the project is to provide online resources to scientists and physicians dedicated to the development of innovative treatments and diagnostics that will enhance the quality of life and survival of patients with brain cancer.$$  as varchar(900)) as c_tooltip,
       cast('NCIt:C47824|Ivy-Gap' as varchar(50)) as c_basecode,
       cast('https://wiki.cancerimagingarchive.net/display/Public/Ivy+GAP' as text) as c_comment
)
,
anatomic_sites as (
select 2 as c_hlevel,
       cast($$\Anatomic Site\C12971\$$  as varchar(700)) as c_fullname, 
       cast('Breast' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Anatomic Site\C12971\$$ as varchar(700)) as c_dimcode,
       cast('One of two hemispheric projections of variable size situated in the subcutaneous layer over the pectoralis major muscle on either side of the chest.' as varchar(900)) as c_tooltip,
       cast('NCIt:C12971' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C12971' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Anatomic Site\C12439\$$  as varchar(700)) as c_fullname, 
       cast('Brain' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Anatomic Site\C12439\$$ as varchar(700)) as c_dimcode,
       cast('An organ composed of grey and white matter containing billions of neurons that is the center for intelligence and reasoning. It is protected by the bony cranium.' as varchar(900)) as c_tooltip,
       cast('NCIt:C12439' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C12439' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Anatomic Site\C12468\$$  as varchar(700)) as c_fullname, 
       cast('Lung' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Anatomic Site\C12468\$$ as varchar(700)) as c_dimcode,
       cast('One of a pair of viscera occupying the pulmonary cavities of the thorax, the organs of respiration in which aeration of the blood takes place. As a rule, the right lung is slightly larger than the left and is divided into three lobes (an upper, a middle, and a lower or basal), while the left has two lobes (an upper and a lower or basal). Each lung is irregularly conical in shape, presenting a blunt upper extremity (the apex), a concave base following the curve of the diaphragm, an outer convex surface (costal surface), an inner or mediastinal surface (mediastinal surface), a thin and sharp anterior border, and a thick and rounded posterior border.' as varchar(900)) as c_tooltip,
       cast('NCIt:C12468' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C12468' as text) as c_comment
)
,
laterality as (
select 2 as c_hlevel,
       cast($$\Laterality\C25229\$$  as varchar(700)) as c_fullname, 
       cast('Left' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Laterality\C25229\$$ as varchar(700)) as c_dimcode,
       cast('Being or located on or directed toward the side of the body to the west when facing north.' as varchar(900)) as c_tooltip,
       cast('NCIt:C25229' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C25229' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Laterality\C25228\$$  as varchar(700)) as c_fullname, 
       cast('Right' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Laterality\C25228\$$ as varchar(700)) as c_dimcode,
       cast('Being or located on or directed toward the side of the body to the east when facing north.' as varchar(900)) as c_tooltip,
       cast('NCIt:C25228' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C25228' as text) as c_comment
) 
, 
prim_dx as (
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C2924\$$  as varchar(700)) as c_fullname, 
       cast('Ductal Breast Carcinoma In Situ' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C2924\$$ as varchar(700)) as c_dimcode,
       cast('A carcinoma entirely confined to the mammary ducts. It is also known as DCIS. There is no evidence of invasion of the basement membrane. Currently, it is classified into three categories: High-grade DCIS, intermediate-grade DCIS and low-grade DCIS. In this classification the DCIS grade is defined by a combination of nuclear grade, architectural growth pattern and presence of necrosis. The size of the lesion as well as the grade and the clearance margins play a major role in dictating the most appropriate therapy for DCIS.' as varchar(900)) as c_tooltip,
       cast('NCIt:C2924' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C2924' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C4194\$$  as varchar(700)) as c_fullname, 
       cast('Invasive Ductal Carcinoma, Not Otherwise Specified' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C4194\$$ as varchar(700)) as c_dimcode,
       cast('The most common type of invasive breast carcinoma, accounting for approximately 70% of breast carcinomas. The gross appearance is usually typical with an irregular stellate outline. Microscopically, randomly arranged epithelial elements are seen. When large sheets of malignant cells are present, necrosis may be seen. With adequate tissue sampling, in situ carcinoma can be demonstrated in association with the infiltrating carcinoma. The in situ component is nearly always ductal but occasionally may be lobular or both.' as varchar(900)) as c_tooltip,
       cast('NCIt:C4194' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C4194' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C3744\$$  as varchar(700)) as c_fullname, 
       cast('Breast Fibroadenoma' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C3744\$$ as varchar(700)) as c_dimcode,
       cast('A benign tumor of the breast characterized by the presence of stromal and epithelial elements. It presents as a painless, solitary, slow growing, firm, and mobile mass. It is the most common benign breast lesion. It usually occurs in women of childbearing age. The majority of fibroadenomas do not recur after complete excision. A slightly increased risk of developing cancer within fibroadenomas or in the breast tissue of patients previously treated for fibroadenomas has been reported.' as varchar(900)) as c_tooltip,
       cast('NCIt:C3744' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C3744' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C7950\$$  as varchar(700)) as c_fullname, 
       cast('Invasive Lobular Breast Carcinoma' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C7950\$$ as varchar(700)) as c_dimcode,
       cast('An infiltrating lobular adenocarcinoma of the breast. The malignant cells lack cohesion and are arranged individually or in a linear manner (Indian files), or as narrow trabeculae within the stroma. The malignant cells are usually smaller than those of ductal carcinoma, are less pleomorphic, and have fewer mitotic figures.' as varchar(900)) as c_tooltip,
       cast('NCIt:C7950' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C7950' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C3039\$$  as varchar(700)) as c_fullname, 
       cast('Breast Fibrocystic Change' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C3039\$$ as varchar(700)) as c_dimcode,
       cast('Fibrosis associated with cyst formation in the breast parenchyma.' as varchar(900)) as c_tooltip,
       cast('NCIt:C3039' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C3039' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C9245\$$  as varchar(700)) as c_fullname, 
       cast('Invasive Breast Carcinoma' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C9245\$$ as varchar(700)) as c_dimcode,
       cast('A carcinoma that infiltrates the breast parenchyma. The vast majority are adenocarcinomas arising from the terminal ductal lobular unit (TDLU). Often, the invasive adenocarcinoma co-exists with ductal or lobular carcinoma in situ. It is the most common carcinoma affecting women.' as varchar(900)) as c_tooltip,
       cast('NCIt:C9245' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C9425' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C3058\$$  as varchar(700)) as c_fullname, 
       cast('Glioblastoma' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C3058\$$ as varchar(700)) as c_dimcode,
       cast('The most malignant astrocytic tumor (WHO grade IV). It is composed of poorly differentiated neoplastic astrocytes and it is characterized by the presence of cellular polymorphism, nuclear atypia, brisk mitotic activity, vascular thrombosis, microvascular proliferation and necrosis. It typically affects adults and is preferentially located in the cerebral hemispheres. It may develop from diffuse astrocytoma WHO grade II or anaplastic astrocytoma (secondary glioblastoma, IDH-mutant), but more frequently, it manifests after a short clinical history de novo, without evidence of a less malignant precursor lesion (primary glioblastoma, IDH- wildtype). (Adapted from WHO)' as varchar(900)) as c_tooltip,
       cast('NCIt:C3058' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C3058' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C60781\$$  as varchar(700)) as c_fullname, 
       cast('Astrocytoma' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C60781\$$ as varchar(700)) as c_dimcode,
       cast('A tumor of the brain or spinal cord showing astrocytic differentiation. It includes the following clinicopathological entities: pilocytic astrocytoma, diffuse astrocytoma, anaplastic astrocytoma, pleomorphic xanthoastrocytoma, and subependymal giant cell astrocytoma.' as varchar(900)) as c_tooltip,
       cast('NCIt:C60781' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C60781' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C9477\$$  as varchar(700)) as c_fullname, 
       cast('Anaplastic Astrocytoma' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C9477\$$ as varchar(700)) as c_dimcode,
       cast('A diffusely infiltrating, WHO grade III astrocytoma with focal or dispersed anaplasia, and a marked proliferative potential. It may arise from a low-grade astrocytoma, but it can also be diagnosed at first biopsy, without indication of a less malignant precursor lesion. It has an intrinsic tendency for malignant progression to glioblastoma. (WHO)' as varchar(900)) as c_tooltip,
       cast('NCIt:C9477' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C9477' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C14172\$$  as varchar(700)) as c_fullname, 
       cast('Benign' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C14172\$$ as varchar(700)) as c_dimcode,
       cast('For neoplasms, a non-infiltrating and non-metastasizing neoplastic process that is characterized by the absence of morphologic features associated with malignancy (e.g., severe atypia, nuclear pleomorphism, tumor cell necrosis, and abnormal mitoses). For other conditions, a process that is mild in nature and not dangerous to health.' as varchar(900)) as c_tooltip,
       cast('NCIt:C14172' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C14172' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C6930\$$  as varchar(700)) as c_fullname, 
       cast('Mixed Neoplasm' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C6930\$$ as varchar(700)) as c_dimcode,
       cast('A neoplasm composed of at least two distinct cellular populations.' as varchar(900)) as c_tooltip,
       cast('NCIt:C6930' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C6930' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C15220+C17998\$$  as varchar(700)) as c_fullname, 
       cast('Unknown' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C15220+C17998\$$ as varchar(700)) as c_dimcode,
       cast('Unknown primary diagnosis.' as varchar(900)) as c_tooltip,
       cast('NCIt:C15220+NCIt:C17998' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C17998' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C4872\$$  as varchar(700)) as c_fullname, 
       cast('Breast Carcinoma' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C4872\$$ as varchar(700)) as c_dimcode,
       cast('A carcinoma arising from the breast, most commonly the terminal ductal-lobular unit. It is the most common malignant tumor in females. Risk factors include country of birth, family history, menstrual and reproductive history, fibrocystic disease and epithelial hyperplasia, exogenous estrogens, contraceptive agents, and ionizing radiation. The vast majority of breast carcinomas are adenocarcinomas (ductal or lobular). Breast carcinoma spreads by direct invasion, by the lymphatic route, and by the blood vessel route. The most common site of lymph node involvement is the axilla.' as varchar(900)) as c_tooltip,
       cast('NCIt:C4872' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C4872' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C35857\$$  as varchar(700)) as c_fullname, 
       cast('Stromal Hyperplasia' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C35857\$$ as varchar(700)) as c_dimcode,
       cast('Stromal Hyperplasia' as varchar(900)) as c_tooltip,
       cast('NCIt:C35857' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C35857' as text) as c_comment
union
select 2 as c_hlevel,
       cast($$\Primary Diagnosis\C3744\$$  as varchar(700)) as c_fullname, 
       cast('Breast Fibroadenoma' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Primary Diagnosis\C3744\$$ as varchar(700)) as c_dimcode,
       cast('A benign tumor of the breast characterized by the presence of stromal and epithelial elements. It presents as a painless, solitary, slow growing, firm, and mobile mass. It is the most common benign breast lesion. It usually occurs in women of childbearing age. The majority of fibroadenomas do not recur after complete excision. A slightly increased risk of developing cancer within fibroadenomas or in the breast tissue of patients previously treated for fibroadenomas has been reported.' as varchar(900)) as c_tooltip,
       cast('NCIt:C3744' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C3744' as text) as c_comment
)
,
age as (
select 2 as c_hlevel,
cast($$\Demographics\C69260\$$ as varchar(700)) as c_fullname,
cast('Age' as varchar(2000)) as c_name,
cast('LA' as varchar(3)) as c_visualattributes,
     cast($$<?xml version="1.0"?>
            <ValueMetadata>
            <Version>3.02</Version>
            <CreationDateTime>11/07/2017 14:53:45</CreationDateTime>
            <TestID>Age</TestID>
             <TestName>Age</TestName>
             <DataType>PosFloat</DataType>
            <Loinc></Loinc>
            <Flagstouse></Flagstouse>
            <Oktousevalues>Y</Oktousevalues>
<LowofLowValue>10</LowofLowValue><HighofLowValue>10</HighofLowValue>
<LowofHighValue>90</LowofHighValue>
<HighofHighValue>90</HighofHighValue>
<EnumValues></EnumValues>
<CommentsDeterminingExclusion>
<Com></Com>
</CommentsDeterminingExclusion>
<UnitValues>
<NormalUnits>Years</NormalUnits>
<EqualUnits>YRS</EqualUnits>
</UnitValues><Analysis><Enums /><Counts /><New /></Analysis>
</ValueMetadata>
$$
 as text) as c_metadataxml,
       cast($$\Demographics\C69260\$$ as varchar(700)) as c_dimcode,
       cast('The age of a person who is the subject in a study.' as varchar(900)) as c_tooltip,
       cast('NCIt:C69260' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C69260'  as text) as c_comment

)
,
gender_tree as (
select 2 as c_hlevel,
       cast($$\Demographics\C28421\$$  as varchar(700)) as c_fullname, 
       cast('Sex' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C28421\$$ as varchar(700)) as c_dimcode,
       cast('The assemblage of physical properties or qualities by which male is distinguished from female; the physical difference between male and female; the distinguishing peculiarity of male or female.'  as varchar(900)) as c_tooltip,
       cast('NCIt:C28421' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C28421'  as text) as c_comment
union
select 3 as c_hlevel,
       cast($$\Demographics\C28421\C16576\$$  as varchar(700)) as c_fullname, 
       cast('Female' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C28421\C16576\$$ as varchar(700)) as c_dimcode,
       cast('A person who belongs to the sex that normally produces ova. The term is used to indicate biological sex distinctions, or cultural gender role distinctions, or both.' as varchar(900)) as c_tooltip,
       cast('NCIt:C16576' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C16576'  as text) as c_comment
union
select 3 as c_hlevel,
       cast($$\Demographics\C28421\C20197\$$  as varchar(700)) as c_fullname, 
       cast('Male' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C28421\C20197\$$ as varchar(700)) as c_dimcode,
       cast('A person who belongs to the sex that normally produces sperm. The term is used to indicate biological sex distinctions, cultural gender role distinctions, or both.' as varchar(900)) as c_tooltip,
       cast('NCIt:C20197' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C20197'  as text) as c_comment
)
,
race_tree as (
select 2 as c_hlevel,
       cast($$\Demographics\C17049\$$  as varchar(700)) as c_fullname, 
       cast('Race' as varchar(2000)) as c_name,
       cast('FA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C17049\$$ as varchar(700)) as c_dimcode,
       cast($$An arbitrary classification of a taxonomic group that is a division of a species. It usually arises as a consequence of geographical isolation within a species and is characterized by shared heredity, physical attributes and behavior, and in the case of humans, by common history, nationality, or geographic distribution.$$ as varchar(900)) as c_tooltip,
       cast('NCIt:C17049' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C17049'  as text) as c_comment
union
select 3 as c_hlevel,
       cast($$\Demographics\C17049\C41261\$$  as varchar(700)) as c_fullname, 
       cast('White' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C17049\C41261\$$ as varchar(700)) as c_dimcode,
       cast('CDISC Definition: Denotes a person with European, Middle Eastern, or North African ancestral origin who identifies, or is identified, as White.' as varchar(900)) as c_tooltip,
       cast('NCIt:C41261' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C41261'  as text) as c_comment
union
select 3 as c_hlevel,
       cast($$\Demographics\C17049\C41259\$$  as varchar(700)) as c_fullname, 
       cast('American Indian or Alaska Native' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C17049\C41259\$$ as varchar(700)) as c_dimcode,
       cast('CDISC Definition: A person having origins in any of the original peoples of North and South America (including Central America), and who maintains tribal affiliation or community attachment. (FDA)' as varchar(900)) as c_tooltip,
       cast('NCIt:C41259' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C41259'  as text) as c_comment
union
select 3 as c_hlevel,
       cast($$\Demographics\C17049\C16352\$$  as varchar(700)) as c_fullname, 
       cast('Black or African American' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C17049\C16352\$$ as varchar(700)) as c_dimcode,
       cast($$CDISC Definition: A person having origins in any of the black racial groups of Africa. Terms such as 'Haitian' or 'Negro' can be used in addition to 'Black or African American.' (FDA)$$ as varchar(900)) as c_tooltip,
       cast('NCIt:C16352' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C16352'  as text) as c_comment
union
select 3 as c_hlevel,
       cast($$\Demographics\C17049\C41260\$$  as varchar(700)) as c_fullname, 
       cast('Asian' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C17049\C41260\$$ as varchar(700)) as c_dimcode,
       cast('CDISC Definition: A person having origins in any of the original peoples of the Far East, Southeast Asia, or the Indian subcontinent including, for example, Cambodia, China, India, Japan, Korea, Malaysia, Pakistan, the Philippine Islands, Thailand, and Vietnam. (FDA)
' as varchar(900)) as c_tooltip,
       cast('NCIt:C41260' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C41260'  as text) as c_comment
union
select 3 as c_hlevel,
       cast($$\Demographics\C17049\C41219\$$  as varchar(700)) as c_fullname, 
       cast('Native Hawaiian or Other Pacific Islander' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C17049\C41219\$$ as varchar(700)) as c_dimcode,
       cast('CDISC Definition: Denotes a person having origins in any of the original peoples of Hawaii, Guam, Samoa, or other Pacific Islands. The term covers particularly people who identify themselves as part-Hawaiian, Native Hawaiian, Guamanian or Chamorro, Carolinian, Samoan, Chuu. (FDA)
' as varchar(900)) as c_tooltip,
       cast('NCIt:C41219' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C41219'  as text) as c_comment
union
select 3 as c_hlevel,
       cast($$\Demographics\C17049\C17998\$$  as varchar(700)) as c_fullname, 
       cast('Unknown' as varchar(2000)) as c_name,
       cast('LA' as varchar(3)) as c_visualattributes,
       cast(NULL as text) as c_metadataxml,
       cast($$\Demographics\C17049\C17998\$$ as varchar(700)) as c_dimcode,
       cast('Unknown race' as varchar(900)) as c_tooltip,
       cast('NCIt:17049+NCIt:C17998' as varchar(50)) as c_basecode,
       cast('https://ncit.nci.nih.gov/ncitbrowser/ConceptReport.jsp?dictionary=NCI_Thesaurus&code=C17998'  as text) as c_comment
)
, 
all_rows as (
select * from level_1 
cross join consts
union 
select * from race_tree cross join consts
union
select * from age cross join consts
union 
select * from anatomic_sites cross join consts
union
select * from laterality cross join consts
union
select * from prim_dx cross join consts
union
select * from survival cross join consts
union
select * from gender_tree cross join consts
union
select * from course_of_disease cross join consts
union
select * from datasets cross join consts
union
select 
c_hlevel, c_fullname, c_name, c_visualattributes, c_metadataxml, c_dimcode, c_tooltip, 
       c_basecode, c_comment,
       c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, m_applied_path,
       update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, c_synonym_cd, c_path, c_symbol, c_totalnum
 from di3metadata.receptors
)
select c_hlevel, c_fullname, c_name, c_visualattributes, c_metadataxml, c_dimcode, c_tooltip, 
       c_basecode, c_comment,
       c_facttablecolumn, c_tablename, c_columnname, c_columndatatype, c_operator, m_applied_path, 
       update_date, download_date, import_date, sourcesystem_cd, valuetype_cd, c_synonym_cd, c_path, c_symbol, c_totalnum 
 from all_rows;

/*
 Now take care of table_access
*/

delete from di3metadata.table_access where c_table_name = 'DI3';

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3_LAT', 'DI3', 'N' , 1 , $$\Laterality\$$ , 
'Laterality' , 'N'  , 'FA' , 
NULL , 'NCIt:C25185' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Laterality\$$ ,  NULL, 'Dominant use or manifestations of one side of the body versus the other; referring to a side of the body or of a structure.' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3_SURV', 'DI3', 'N' , 1 , $$\Survival Status\$$ , 
'Vital Status' , 'N'  , 'FA' , 
NULL , 'NCIt:C25717' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Vital Status\$$ ,  NULL, 'The state or condition of being living or deceased; also includes the case where the vital status is unknown.' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3_DATASET', 'DI3', 'N' , 1 , $$\Data Set\$$ , 
'Data Set' , 'N'  , 'FA' , 
NULL , 'NCIt:C47824' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Data Set\$$ ,  NULL, 'Data Set' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3_SITE', 'DI3', 'N' , 1 , $$\Anatomic Site\$$ , 
'Anatomic Site' , 'N'  , 'FA' , 
NULL , 'NCIt:C13717' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Anatomic Site\$$ ,  NULL, 'Named locations of or within the body.' , 
current_timestamp , current_timestamp , NULL, NULL) ;
insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3_RECEPTOR', 'DI3', 'N' , 1 , $$\A19046186\$$ , 
'Receptor Status' , 'N'  , 'FA' , 
NULL , 'NCIt:C94299' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\A19046186\$$ ,  NULL, 'Receptor Status' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3_PRIM_DX', 'DI3', 'N' , 1 , $$\Primary Diagnosis\$$ , 
'Primary Diagnosis' , 'N'  , 'FA' , 
NULL , 'NCIt:C15220' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Primary Diagnosis\$$ ,  NULL, 'The investigation, analysis and recognition of the presence and nature of disease, condition, or injury from expressed signs and symptoms; also, the scientific determination of any kind; the concise results of such an investigation.' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3_CLINICAL_COURSE_OF_DISEASE', 'DI3', 'N' , 1 , $$\Clinical Course of Disease\$$ , 
'Clinical Course of Disease' , 'N'  , 'FA' , 
NULL , 'NCIt:C35461' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Clinical Course of Disease\$$ ,  NULL, 'A description of the series of events, including signs and symptoms, that define the course of a chronic disease over time.' , 
current_timestamp , current_timestamp , NULL, NULL) ;

insert into di3metadata.table_access(c_table_cd, c_table_name, c_protected_access, c_hlevel, c_fullname, c_name, c_synonym_cd, 
      c_visualattributes, c_totalnum, c_basecode, c_metadataxml, c_facttablecolumn , c_dimtablename,c_columnname, 
      c_columndatatype, c_operator, c_dimcode, c_comment, c_tooltip, c_entry_date, c_change_date, c_status_cd, valuetype_cd )
values (
'DI3_DEMO', 'DI3', 'N' , 1 , $$\Demographics\$$ , 
'Demographics' , 'N'  , 'FA' , 
NULL , 'NCIt:C16495' , NULL, 
'CONCEPT_CD' , 'CONCEPT_DIMENSION' , 'CONCEPT_PATH' , 'T' , 
'LIKE' , $$\Demographics\$$ ,  NULL, 'The statistical characterization of human populations or segments of human populations (e.g., characterization by age, sex, race, or income).' , 
current_timestamp , current_timestamp , NULL, NULL) ;
