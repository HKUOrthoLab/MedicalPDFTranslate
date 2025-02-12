--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10
-- Dumped by pg_dump version 15.10

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: machine_translations; Type: TABLE; Schema: public; Owner: translator
--

CREATE TABLE public.machine_translations (
    id integer NOT NULL,
    translation_id integer,
    translated_text text NOT NULL,
    frequency integer DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.machine_translations OWNER TO translator;

--
-- Name: machine_translations_id_seq; Type: SEQUENCE; Schema: public; Owner: translator
--

CREATE SEQUENCE public.machine_translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.machine_translations_id_seq OWNER TO translator;

--
-- Name: machine_translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: translator
--

ALTER SEQUENCE public.machine_translations_id_seq OWNED BY public.machine_translations.id;


--
-- Name: translations; Type: TABLE; Schema: public; Owner: translator
--

CREATE TABLE public.translations (
    id integer NOT NULL,
    source_text text NOT NULL,
    confirmed_translation text,
    is_confirmed boolean DEFAULT false,
    return_original boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.translations OWNER TO translator;

--
-- Name: translations_id_seq; Type: SEQUENCE; Schema: public; Owner: translator
--

CREATE SEQUENCE public.translations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.translations_id_seq OWNER TO translator;

--
-- Name: translations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: translator
--

ALTER SEQUENCE public.translations_id_seq OWNED BY public.translations.id;


--
-- Name: machine_translations id; Type: DEFAULT; Schema: public; Owner: translator
--

ALTER TABLE ONLY public.machine_translations ALTER COLUMN id SET DEFAULT nextval('public.machine_translations_id_seq'::regclass);


--
-- Name: translations id; Type: DEFAULT; Schema: public; Owner: translator
--

ALTER TABLE ONLY public.translations ALTER COLUMN id SET DEFAULT nextval('public.translations_id_seq'::regclass);


--
-- Data for Name: machine_translations; Type: TABLE DATA; Schema: public; Owner: translator
--

COPY public.machine_translations (id, translation_id, translated_text, frequency, created_at) FROM stdin;
2	2	01 预防近视手术	1	2025-02-08 15:24:29.585391
3	3	Please maintain eye hygiene and regularly visit an optician to have an optical examination.	1	2025-02-08 15:24:33.577497
4	4	02. Chronic Throat Inflammation	1	2025-02-08 15:24:42.884713
5	5	1. Chronic throat infection primarily occurs in conditions where upper respiratory infections are treated without complete relief or are sustained by long-term exposure to both food-related and environmental (为空气)刺激.\n\n2. Such cases often result in an uninitiated flare-up, accompanied by symptoms such as a swollen or enlarged throat.	1	2025-02-08 15:24:50.615618
6	6	An unsettling feeling, 𝑝𝑎𝑛𝑒𝑐𝑐𝑜𝑡𝑖𝑎𝑛𝑔𝑒𝑛𝑑ing, and 𝑐𝑎𝑡𝑎𝑠$t𝑎$c$h$i$b$-$𝑟𝑒$c𝑒$n$𝑡$-$𝑛𝑐𝑒$s.	1	2025-02-08 15:24:59.180969
7	7	2. Avoid long-term stimulation of productivity and alcohol, smoke and drink water, keep bowel passage flowing smoothly.	1	2025-02-08 15:25:09.743532
8	8	cheerful	1	2025-02-08 15:25:15.616775
9	9	3、In environments containing smoke or atmospheric irritants, workers should wear a口罩.	1	2025-02-08 15:25:22.781068
10	10	4、症状严重、反复发作时，应去医院八鼻咽喉科治疗。	1	2025-02-08 15:25:30.268033
11	11	03.calcium accumulation in the calcaneus; narrowing of the calcaneus spine neck	1	2025-02-08 15:25:39.648947
12	12	The Shanghai Jinhua Road Hospital Center in Jiangsu Area Branch of the Shanghai Jinhua Jiaoban Group Company	1	2025-02-08 15:25:47.362397
13	13	Unified Report Interpretation Line**: 400-081-8899	1	2025-02-08 15:26:01.454971
14	14	download an app	1	2025-02-08 15:26:09.829415
15	15	View彩辣椒 reports	1	2025-02-08 15:26:15.461455
17	17	Aging Angel康哥 has a Health体检报告.	1	2025-02-08 15:26:16.111885
19	19	first name 2005499272 identification number 1522206240111	1	2025-02-08 15:26:28.794161
20	20	3. Health Physical Examination Result	1	2025-02-08 15:26:35.660232
21	21	checkers:	1	2025-02-08 15:26:44.967667
22	22	Chen Xufeng	1	2025-02-08 15:26:55.493247
23	23	Data validation of the project integrity	1	2025-02-08 15:26:55.844096
24	24	Measured Results	1	2025-02-08 15:27:05.975754
26	26	Anomalies	1	2025-02-08 15:27:11.734815
29	29	The term weight refers to the amount of mass or quantity in a given object.	1	2025-02-08 15:27:22.66623
30	30	Caloric Expenditure	1	2025-02-08 15:27:32.490043
31	31	contraction pressure	1	2025-02-08 15:27:32.829651
32	32	Diastolic pressure	1	2025-02-08 15:27:40.586262
33	33	Initial estimates	1	2025-02-08 15:27:40.893399
34	34	no obvious symptoms	1	2025-02-08 15:27:41.150122
35	21	检查者：  \n（作为翻译助手，请将中文内容准确翻译为英文，并保留原文结构和格式，不添加其他解释或信息。）	1	2025-02-08 15:27:50.225829
36	23	Check out the project	1	2025-02-08 15:27:55.833762
37	35	Check out what you see	1	2025-02-08 15:28:00.727921
38	25	Unit	1	2025-02-08 15:28:07.38672
40	37	There is nothing.	1	2025-02-08 15:28:16.129934
42	39	There is no special.	1	2025-02-08 15:28:16.706589
44	41	subsequent/minutes	1	2025-02-08 15:28:21.656579
49	46	lungs; abdominal lung sounds	1	2025-02-08 15:28:44.87511
50	47	double breathing声 not heard from any other source	1	2025-02-08 15:28:49.656681
51	48	Touchedhearscontact	1	2025-02-08 15:28:56.083507
52	49	The liver in the ribcage is not being pierced.	1	2025-02-08 15:29:00.523517
53	50	sensory liver touch	1	2025-02-08 15:29:07.783596
54	51	Tendons and organs beneath the脾 do not yet be touched.	1	2025-02-08 15:29:13.919247
56	53	No pain in the double kidney area	1	2025-02-08 15:29:24.464139
57	54	Other Sections	1	2025-02-08 15:29:35.014424
59	55	Preliminary assessment, no obvious abnormalities	1	2025-02-08 15:29:45.482811
60	12	The Hospital Center Named After [Name] And Part Of A Medical Clinic	1	2025-02-08 15:29:53.99648
61	13	400-081-8899 is the Analyses of Report 400-081-8899.	1	2025-02-08 15:30:04.968234
62	19	First Life. G Identification 2005499272 Medical ID 1522206240111	1	2025-02-08 15:30:14.12616
63	56	Econsophominoes of China	1	2025-02-08 15:30:21.959125
64	57	health insurance review report	1	2025-02-08 15:30:22.416034
65	16	Here’s the original text with a translation to English, keeping its structure and format intact without any additional explanations:\n\n**Note:** Additional Terms	1	2025-02-08 15:30:29.382025
66	14	Download Aurex App	1	2025-02-08 15:30:30.294497
68	1	2. Expert suggestions and guidance	1	2025-02-09 14:07:37.537199
69	2	First page after surgery	1	2025-02-09 14:07:40.454647
70	3	always make sure you are well,\n\nif you are sick, it's always good to check again,\n\neverytime your eyes need care.	1	2025-02-09 14:07:43.898098
71	4	02 Asphylaxia	1	2025-02-09 14:07:57.360688
72	5	1. Chronic sinuses mainly occur when there is a persistent and ineffective systemic inflammatory response to马丁体 (stomach acid) or prolonged exposure to foodborne Martin body刺激 results.	1	2025-02-09 14:07:57.748841
73	6	Perceptible object, severally boils up to be very痒, arising from the burning of the body.	1	2025-02-09 14:08:07.16253
74	7	2. Avoid long-term use of cleaning products, tobacco, alcohol, and excessive water.	1	2025-02-09 14:08:15.908476
75	8	y'all	1	2025-02-09 14:08:21.176883
76	9	在有烟尘或刺激性空气环境中工作时，必须佩戴口罩。	1	2025-02-09 14:08:27.99832
77	10	4、Recurring occurrences of serious symptoms should prompt a visit to the sinous and oropharyonic department.	1	2025-02-09 14:08:37.851854
78	11	03 项韧带部分钙化；颈椎 生理曲度变直	1	2025-02-09 14:08:47.801342
79	12	China Jiaoxi Yizhuangjiang Road Branch  \n（杭州爱康国宾江南大道医疗口腔店有限公司）	1	2025-02-09 14:08:53.329021
80	13	United Law and Policy Manual Explaining the 400-081-8899 Line: Numbering Information for Application.	1	2025-02-09 14:09:00.726457
81	14	Download an app	1	2025-02-09 14:09:07.767936
67	15	Examine the color report.	2	2025-02-08 15:30:36.864561
28	28	height	5	2025-02-08 15:27:22.419964
25	25	unit	10	2025-02-08 15:27:06.239519
27	27	reference interval	3	2025-02-08 15:27:17.31963
47	44	Heartbeat	3	2025-02-08 15:28:44.376466
45	42	heart rate	5	2025-02-08 15:28:32.38917
39	36	Disease history	2	2025-02-08 15:28:15.843012
43	40	heart rate	4	2025-02-08 15:28:17.041703
48	45	Normal	3	2025-02-08 15:28:44.627666
18	18	王海鹏	2	2025-02-08 15:26:24.235821
1	1	2. 专家建议与指导	2	2025-02-08 15:24:23.427099
41	38	Family History	3	2025-02-08 15:28:16.455567
58	37	None	2	2025-02-08 15:29:40.882766
46	43	齐	4	2025-02-08 15:28:32.642223
83	16	**Note: Major Terms**\n\n（注意：重点词汇）	1	2025-02-09 14:09:15.177394
84	17	Evan conservation, a Medical Examination Report	1	2025-02-09 14:09:15.710498
85	18	Wang Haipeng	1	2025-02-09 14:09:21.066659
86	19	First-generation.<span class="font-semibold">ID</span> 2005-4992-72, <span class="font-semibold">体检号</span> 1522206240111	1	2025-02-09 14:09:21.408425
87	20	The results of the physical examination	1	2025-02-09 14:09:23.007935
88	21	Checkers:\n  \nPlease provide the specific text you would like translated into English, so I can perform this task accurately and effectively.	1	2025-02-09 14:09:27.62514
89	22	Chen Peifang	1	2025-02-09 14:09:32.714105
91	24	The results of the measurements.	1	2025-02-09 14:09:33.349764
92	25	one unit	1	2025-02-09 14:09:37.984553
97	30	weight index	1	2025-02-09 14:09:50.464154
98	31	收缩压 - Diastolic Blood Pressure	1	2025-02-09 14:09:57.038516
99	32	systolic pressure	1	2025-02-09 14:10:03.858213
100	33	Initial assessment	1	2025-02-09 14:10:07.856406
101	34	No obvious signs of abnormality	1	2025-02-09 14:10:08.107595
102	21	"I'm a checker."	1	2025-02-09 14:10:08.469494
103	23	Evaluating project	1	2025-02-09 14:10:13.071532
104	35	Check what you've seen.	1	2025-02-09 14:10:17.868493
107	37	No	1	2025-02-09 14:10:23.026683
108	38	Genetic DNA traces were discovered in an unknown family to help determine the true gender of the person, the findings of a study led by scientists at the University of North Carolina said on Monday.\n\nFive individuals whose genetic material was traced back to the same DNA molecule have now been identified as the parents of a 15-year-old girl with a rare condition called hemophilia, according to the study. The researchers found that when these two people were born to each other, they inherited an X chromosome from their mother and a Y chromosome from their father.\n\nThe study was published in the journal Blood in the News. The team discovered the genes after they found DNA traces in blood samples from the girl's mother during a routine checkup.	1	2025-02-09 14:10:23.266776
109	39	无特殊	1	2025-02-09 14:10:27.124362
111	41	subsequent/to measure time	1	2025-02-09 14:10:37.204933
112	42	heartbeats	1	2025-02-09 14:10:41.619139
113	43	Yes, I can do that for you.	1	2025-02-09 14:10:41.89676
114	44	the voice	1	2025-02-09 14:10:42.338603
116	46	Spinal exam	1	2025-02-09 14:10:42.829866
117	47	Double respiratory sound, not heard and showing abnormal features.	1	2025-02-09 14:10:43.123761
118	48	Testing in Lungs	1	2025-02-09 14:10:50.364238
119	49	The liver's ribcage is not yet accessible.	1	2025-02-09 14:10:55.365195
120	50	palpity for the liver	1	2025-02-09 14:11:03.100827
121	51	liver subdeltoid unreached	1	2025-02-09 14:11:03.436132
123	53	The back of both kidneys have no pain.	1	2025-02-09 14:11:16.255973
124	54	The other aspects of traditional medicine, excluding the traditional methods in内科.	1	2025-02-09 14:11:24.840775
125	37	There is no content provided for translation.	1	2025-02-09 14:11:30.035004
126	55	Preliminary conclusions were made, and no obvious symptoms or concerning signs were observed.	1	2025-02-09 14:11:30.461594
127	12	The branch of the hospital at Jia Road, Yangzhou, Jiangsu, China is called "Jia Road, Yangzhou Hospital Branch." Its medical division is known as "Yangzhou Medical Division" in Chinese.	1	2025-02-09 14:11:34.983279
128	13	The official release of the national report: 400-081-8899	1	2025-02-09 14:11:42.878281
129	19	First Name: 王某  \nLast Name: 李某  \nSex: Male  \nAge: 38  \nEthnic Group: Chinese  \nID Number: 2005499272  \n体检号: 1522206240111	1	2025-02-09 14:11:43.635367
130	56	Paul Schoukens and Gongbing conduct an interaction study.	1	2025-02-09 14:11:45.48174
133	14	Download Aqcom App	1	2025-02-09 14:11:57.981093
134	15	View Color Report	1	2025-02-09 14:12:05.95614
136	2	01 After Eyeglass or Meniscus Removal	1	2025-02-09 14:32:19.724003
137	3	I strongly recommend that you pay attention to eye health regularly and visit the optical care center定期检查视力.	1	2025-02-09 14:32:20.242341
138	4	02. Chronic Sore Throat	1	2025-02-09 14:32:26.348854
139	5	mesoredema mainly occur when genomal airway infection is not fully cured or has long-term acute medial food or ambient food exposure, commonly invade the nasal passages	1	2025-02-09 14:32:26.780907
140	6	An overwhelming sensation,狂热,狂痒, and作呕 symptoms.	1	2025-02-09 14:32:34.834053
141	7	2、 Avoid prolonged absorption of harmful substances and烟酒. Use distilled water to flush out residues frequently, can be used for supplementary items, staying hydrated while maintaining urination.	1	2025-02-09 14:32:40.40931
142	8	clear	1	2025-02-09 14:32:51.009185
143	9	In environments with harmful air or toxic particles, workers must wear a mask when working.	1	2025-02-09 14:32:56.593514
144	10	4. When severe symptoms occur repeatedly, see a chief care physician at theopharyngeal and tonal科 during this time.	1	2025-02-09 14:33:02.981412
145	11	Third PCT.calcium hypoplasia in the ligaments; Neurosciences neck curve becomes normal.	1	2025-02-09 14:33:11.607968
146	12	Hangzhou Hongta Medical Center Division, Hangzhou Hongtan pharmacy	1	2025-02-09 14:33:21.745319
147	13	One National Standardized Report Interpretation Lines: 400-081-8899	1	2025-02-09 14:33:29.74313
148	14	Download the EgoApp	1	2025-02-09 14:33:36.010537
149	15	Look at the color report.	1	2025-02-09 14:33:39.072067
150	16	In addition, the following terms are increased:	1	2025-02-09 14:33:39.444579
151	17	Evan Koon-Wai, Health Examination Report	1	2025-02-09 14:33:39.885891
152	18	Wen Huaping	1	2025-02-09 14:33:47.379436
153	19	First born ID: 2005499272  \n体检号:1522206240111	1	2025-02-09 14:33:47.674357
154	20	3. health check-up results	1	2025-02-09 14:33:51.402004
155	21	Investigator:	1	2025-02-09 14:33:58.889089
157	23	verifying the items	1	2025-02-09 14:34:08.867095
158	24	测量结果	1	2025-02-09 14:34:18.100216
160	26	exceptions描述	1	2025-02-09 14:34:27.955762
162	28	Height	1	2025-02-09 14:34:28.483039
106	36	Disease History	3	2025-02-09 14:10:22.749347
164	30	BMI	1	2025-02-09 14:34:28.964236
165	31	hypertension	1	2025-02-09 14:34:29.207265
167	33	Initial Estimates	1	2025-02-09 14:34:38.047244
93	26	abnormal description	3	2025-02-09 14:09:43.967599
156	22	Nina Chen	2	2025-02-09 14:34:05.133007
161	27	Reference interval	3	2025-02-09 14:34:28.230227
96	29	weight	3	2025-02-09 14:09:50.171445
131	57	Medical Examination Report	2	2025-02-09 14:11:53.694754
166	32	diastolic blood pressure	2	2025-02-09 14:34:37.694927
16	16	Note: Additional terms	3	2025-02-08 15:26:15.78882
135	1	2. Expert advice and guidance	2	2025-02-09 14:32:11.557361
90	23	Check the project	5	2025-02-09 14:09:33.079284
168	34	Unobserved clearly abnormal situation	1	2025-02-09 14:34:38.295302
169	21	Reviewers:	1	2025-02-09 14:34:43.988522
171	35	Examine what you see.	1	2025-02-09 14:34:53.49216
174	37	There is no content to translate.	1	2025-02-09 14:35:01.928576
176	39	Nothing special.	1	2025-02-09 14:35:10.698237
178	41	Next/After	1	2025-02-09 14:35:18.13785
183	46	Lung listening	1	2025-02-09 14:35:28.356907
184	47	Double-sided respiratory sounds were unreported and concerning anomalies.	1	2025-02-09 14:35:32.214371
185	48	Liver Tap Test	1	2025-02-09 14:35:36.913515
186	49	Liver ribcage is not touched	1	2025-02-09 14:35:46.71248
187	50	palpable rectum	1	2025-02-09 14:35:55.408295
188	51	Tibial area not yet explored	1	2025-02-09 14:35:55.737603
190	53	double kidney region without pain	1	2025-02-09 14:36:06.705395
191	54	Other内科	1	2025-02-09 14:36:15.709494
193	55	Initial opinion; non-obvious anomalies	1	2025-02-09 14:36:16.327491
194	12	The hospital branch located at 201 Shuicheng Road, Shanghai City, along the improve High Road in Shanghai.	1	2025-02-09 14:36:25.959548
195	13	全国统一通	1	2025-02-09 14:36:35.846707
196	19	First Name mosquito ID 2005499272  \nbirth record number 1522206240111	1	2025-02-09 14:36:41.233741
197	56	Aekon Ahn Kim	1	2025-02-09 14:36:48.333156
198	57	health examination report	1	2025-02-09 14:36:53.107613
199	16	note: higher terms	1	2025-02-09 14:36:59.884321
200	14	Download an app named "Lianke"	1	2025-02-09 14:37:00.211341
201	15	View彩色 reports.	1	2025-02-09 14:37:06.821404
203	2	01. Post-Operative First Day	1	2025-02-09 14:38:53.046607
204	3	Noticing that it's important to always visit the lens科 check regularly.	1	2025-02-09 14:38:59.572159
205	4	Chronic sinusitis	1	2025-02-09 14:39:07.169582
206	5	1. Chronic sinusitis is primarily associated with upper respiratory infections that are not fully treated or result from long-term stimulation from both food and air, often accompanied by sinus-related symptoms.\n\n2. chronic sinusitis mainly develops due to severe complications of an upper respiratory infection, which occurs frequently during prolonged exposure to both food and air, often accompanied by sinus-related issues.	1	2025-02-09 14:39:14.217265
207	6	fever, curly hair, itching, and Gastricenteritis	1	2025-02-09 14:39:24.930077
208	7	2. Avoid long-time eating and consuming food,烟 and wine, such as saltwater漱 mouth.	1	2025-02-09 14:39:30.655161
209	8	progressing	1	2025-02-09 14:39:40.348812
210	9	3、在有烟尘或刺激性空气环境中工作时应佩戴口罩。	1	2025-02-09 14:39:47.794009
211	10	Number 4. I have a severe and recurrent issue, so I should go to the nose and throat department.	1	2025-02-09 14:39:55.609016
212	11	03 项ligament partial calciumization；椎索 normalizes spinal curvature	1	2025-02-09 14:40:03.351038
213	12	Jingzhou Hangzhou Huihuang Road Branches Jiaxing Jinhua Huihuang Road Medical Branches	1	2025-02-09 14:40:09.469471
214	13	全国统⼀报告解读专线：400-081-8899	1	2025-02-09 14:40:16.907242
215	14	Download the Love康App	1	2025-02-09 14:40:23.740872
216	15	View a color report	1	2025-02-09 14:40:35.462645
217	16	note: increasing terms	1	2025-02-09 14:40:42.019156
218	17	Evan O'Conner - Health Exam Report	1	2025-02-09 14:40:42.341986
219	18	Wen Hau-peng	1	2025-02-09 14:40:48.020628
220	19	Firstly, we have ID number 2005499272 and examination number 1522206240111.	1	2025-02-09 14:40:48.40255
221	20	Wellness体检 results	1	2025-02-09 14:40:49.576624
222	21	Inspectors:	1	2025-02-09 14:40:53.374964
224	23	Review the project.	1	2025-02-09 14:40:59.398919
225	24	Measurements	1	2025-02-09 14:41:05.536362
230	29	person's weight	1	2025-02-09 14:41:12.594028
231	30	weight index statistic	1	2025-02-09 14:41:16.920218
232	31	Diastolic blood pressure	1	2025-02-09 14:41:22.379165
233	32	Systolic pressure	1	2025-02-09 14:41:22.773348
234	33	initial findings	1	2025-02-09 14:41:31.066902
235	34	Unseen obvious anomalies	1	2025-02-09 14:41:38.639109
236	21	Checker	1	2025-02-09 14:41:39.00713
237	23	Check the system requirements and perform a thorough testing of each component.	1	2025-02-09 14:41:46.330107
238	35	Check out what's in the room	1	2025-02-09 14:41:52.319456
241	37	无	1	2025-02-09 14:41:53.252021
243	39	There's no special	1	2025-02-09 14:42:01.066618
245	41	next/within	1	2025-02-09 14:42:01.678166
248	44	Echoes	1	2025-02-09 14:42:02.467916
182	45	normal	2	2025-02-09 14:35:24.778326
250	46	spirometry	1	2025-02-09 14:42:02.949663
251	47	Dual-sided respiratory sound is not reported as abnormalities.	1	2025-02-09 14:42:03.240058
252	48	hearing the liver through touch or palpation	1	2025-02-09 14:42:08.332405
253	49	Hepatium肋下未触及	1	2025-02-09 14:42:19.606961
254	50	The palpation test of the脾 (tuscle)	1	2025-02-09 14:42:26.592719
255	51	Uninfected hepatocellular tumor located in uninfected肋骨下部.	1	2025-02-09 14:42:30.734472
257	53	Both kidneys are pain-free.	1	2025-02-09 14:42:41.743547
258	54	Mental Health Other	1	2025-02-09 14:42:42.158632
259	37	There is no content provided. Please provide the text you'd like translated, and I will translate it to English while maintaining its original structure and format.	1	2025-02-09 14:42:42.476101
260	55	Initial assessment No noticeable abnormalities	1	2025-02-09 14:42:43.507454
261	12	The Medical Practice Center located at Haocong Medical Center, Haidong Road, Hangzhou, and Shanghai Medical Diary Branch, Haocong Medical Center is established in Hangzhou and Shanghai.	1	2025-02-09 14:42:53.375037
262	13	The national unified report reading line is 400-081-8899. This format is typical in North America for national unified reports. It includes three-digit numbers separated by commas and a four-digit area code where applicable. The local contact number would be 081-8899.	1	2025-02-09 14:43:04.453152
263	19	First Name’s Social Security Number (SSN) 2005499272  \n1522206240111	1	2025-02-09 14:43:15.866415
264	56	The Ego康护士	1	2025-02-09 14:43:26.317552
265	57	健康体检报告  \nHealth Exam Report	1	2025-02-09 14:43:26.684516
266	16	Arrow Term	1	2025-02-09 14:43:30.925673
267	14	download App	1	2025-02-09 14:43:39.956
268	15	inspect the color report	1	2025-02-09 14:43:43.397677
269	1	2. Expert guidance or expert advice	1	2025-02-09 14:44:37.152651
270	2	01 Postoperative视力	1	2025-02-09 14:44:43.843286
271	3	Please pay attention to eye hygiene, and check regularly with your optometrist at your scheduled eye exam appointment.	1	2025-02-09 14:44:44.216911
272	4	The second item, chronic cough.	1	2025-02-09 14:44:50.711717
273	5	1. Chronic sinusitis is mostly associated with untreated upper respiratory infections or long-term sensory刺激（like bacteria, dust, etc.）resulting in sinuses.	1	2025-02-09 14:44:59.703982
274	6	perceptual anorexia, gut feeling acne, and gut feeling(acne)	1	2025-02-09 14:45:05.662467
275	7	2、 Avoid long-time consumption of ingredients that cause irritation and smoke, alcohol. May consume a healthful tea, drink enough water, ensure the stool is well-about it.\n\n3、 Ensure stool flow.\n\n4、 Avoid excessive consumption of milk products and high sugar soft drinks.\n\n5. Note the proper hygiene, avoid pathogenic foods.\n\n6. No use of chemical additives to stimulate flavor.	1	2025-02-09 14:45:13.301166
276	8	Open	1	2025-02-09 14:45:22.460982
277	9	3、In environments with smoke or harmful air, work should wear a mask.	1	2025-02-09 14:45:35.721822
278	10	症状严重、反复发作时，应去医院鼻咽喉科治疗。	1	2025-02-09 14:45:43.6741
279	11	03项韧带部分钙化；颈椎生理曲度变直	1	2025-02-09 14:45:50.559165
280	12	The Address of the Division of杭州滨江江南大道分院 located at (杭州爱康国宾江南大道) medical billing and inspection部有限公司.	1	2025-02-09 14:46:01.167404
281	13	全国统一报告解读专线：400-081-8899	1	2025-02-09 14:46:08.565266
282	14	download an app called	1	2025-02-09 14:46:16.379845
283	15	View the hue report	1	2025-02-09 14:46:25.775573
284	16	Note: No mention of the fee increase term.	1	2025-02-09 14:46:26.094286
285	17	E康国宾. Health体检报告. MEDICAL EXAMINATION REPORT	1	2025-02-09 14:46:32.593482
287	19	Father ID 2005499272,身份证号 1522206240111	1	2025-02-09 14:46:36.858927
288	20	3. Health examination results	1	2025-02-09 14:46:42.34824
289	21	Checker:	1	2025-02-09 14:46:50.304493
290	22	Ms. Chen Peifeng	1	2025-02-09 14:46:59.525582
292	24	Measurement Results	1	2025-02-09 14:47:03.956836
298	30	body index	1	2025-02-09 14:47:33.040139
299	31	收缩压（Systolic Pressure）	1	2025-02-09 14:47:39.34947
300	32	diploma pressure	1	2025-02-09 14:47:52.808395
301	33	Initial Assessments	1	2025-02-09 14:47:57.004113
302	34	The absence of noticeable anomalies	1	2025-02-09 14:48:01.067112
303	21	Test Runner	1	2025-02-09 14:48:09.721816
304	23	checks project	1	2025-02-09 14:48:16.469467
305	35	inspect	1	2025-02-09 14:48:22.503627
309	38	家族历史	1	2025-02-09 14:48:29.701386
310	39	No special	1	2025-02-09 14:48:35.139211
311	40	心率	1	2025-02-09 14:48:35.391526
312	41	next/next/previous/previous	1	2025-02-09 14:48:39.688548
314	43	Hello, I'm here to help with your English translation. Whether you need assistance translating specific content or anything else, please let me know how I can assist you!	1	2025-02-09 14:48:47.891512
315	44	heart sound	1	2025-02-09 14:48:48.954136
317	46	hearing in the lungs (or eardrum), electrocardiogram (ECG)	1	2025-02-09 14:48:55.4113
318	47	双侧呼吸音未闻及异常\nbinaural noise detected at both ears and reported as unreported and abnormal	1	2025-02-09 14:49:04.988284
319	48	touched liver	1	2025-02-09 14:49:16.550042
320	49	Liver (Hepatic) - 进行了ribozyme分析未触及	1	2025-02-09 14:49:23.312358
321	50	Tumors of the spleen	1	2025-02-09 14:49:33.081592
322	51	Biliary and gallbladder regions below the ribcage are not sensitive.	1	2025-02-09 14:49:33.497229
324	53	No pain in the discalciumin region.	1	2025-02-09 14:49:45.321395
325	54	Nursing Other	1	2025-02-09 14:49:51.030937
192	37	There is no text provided.	2	2025-02-09 14:36:15.96262
327	55	Initial opinion No significant abnormalities detected	1	2025-02-09 14:49:51.689642
328	12	East China Yangzhou Avenue No. 2 Middle Office Center, Hangzhou Huanxing Group No. 2 East China Yangzhou Avenue Medical Branch Co., Ltd.	1	2025-02-09 14:49:59.716854
329	13	The detailed解读 of the national unified report: 400-081-8899	1	2025-02-09 14:50:09.273849
330	19	First Name ID 2005499272; ID Number 1522206240111	1	2025-02-09 14:50:14.971226
331	56	Economonion	1	2025-02-09 14:50:24.876598
334	14	Download the ECHO app.	1	2025-02-09 14:50:38.402431
335	15	View the color report	1	2025-02-09 14:50:38.766928
337	2	First postoperative resorced eyes.	1	2025-02-10 06:07:17.810653
338	5	1. Chronic cototonic airway infection predominantly manifests after non-fortified diner food or environmental stimuli acting for long periods, often occupying the throat.	1	2025-02-10 06:07:24.261705
339	6	Nerdy feeling, irritation, and rectlessness symptoms.	1	2025-02-10 06:07:31.974192
340	7	2、避免长期饮用刺激性食物及烟酒。常见使用淡盐水漱口。还可以饮用补品茶。多喝水，保持便利。	1	2025-02-10 06:07:39.088558
341	8	pleasance	1	2025-02-10 06:07:46.402847
342	9	3. In environments with smoke or toxic fumes, work-appropriate face masks must be worn.	1	2025-02-10 06:07:57.749952
343	10	4、症状严重、反复发作时，应去医院鼻腔中耳科治疗。	1	2025-02-10 06:08:04.889111
344	11	03 orthogonal bone union;椎骨正常的曲径变直	1	2025-02-10 06:08:15.299913
345	12	The Chinese medicine clinic located at the East China Industry Road, Hangzhou, along the East China Industrial Road of Hangzhou, Hangzhou Medical Hospital Center.	1	2025-02-10 06:08:24.654379
346	13	全国统⼀热线：400-081-8899	1	2025-02-10 06:08:33.088191
347	14	Download the E 应用程序	1	2025-02-10 06:08:37.724585
348	17	Eva Knudsen has a Medical Examination Report.	1	2025-02-10 06:08:43.866269
349	19	Father's ID: 2005499272  \n体检号: 1522206240111	1	2025-02-10 06:08:50.704196
350	20	3. Health Check-Up Results	1	2025-02-10 06:08:51.811739
351	21	Checklist: Auditors	1	2025-02-10 06:08:57.696105
352	22	Nurul Abida	1	2025-02-10 06:09:10.065597
354	24	measurements results	1	2025-02-10 06:09:10.750348
356	26	An inconsistent explanation of a fact	1	2025-02-10 06:09:18.04993
359	30	body fat percentage index	1	2025-02-10 06:09:38.571799
360	31	Systolic Pressure	1	2025-02-10 06:09:47.890066
362	33	initial assessment or judgment	1	2025-02-10 06:09:52.162687
363	21	inspectors:	1	2025-02-10 06:09:59.089894
366	41	Subordinate to minute	1	2025-02-10 06:10:09.319585
370	47	double-sided breath sounds were unheard or irregular	1	2025-02-10 06:10:16.006633
371	48	Tactile examination of liver	1	2025-02-10 06:10:21.843566
372	49	he artis subtlety not intruding	1	2025-02-10 06:10:22.196342
373	50	hepatobiliary organs examination	1	2025-02-10 06:10:29.064695
374	51	Not yet reached or touched the hearth organ at the thoracic region.	1	2025-02-10 06:10:38.149265
375	58	knee examination	1	2025-02-10 06:10:50.5097
376	12	Divisions of medical units at Shanghai Chinese Medical University Health Center, (Shanghai Shihai Jiangang Division Medical Rooms Inc.)	1	2025-02-10 06:11:01.677263
377	13	全国统一电话号码：400-081-8899	1	2025-02-10 06:11:08.381288
378	19	Firstname_ID 2005499272 体检号 1522206240111	1	2025-02-10 06:11:15.202043
379	57	health inspection report	1	2025-02-10 06:11:22.626524
380	14	Download the EpidemioApp	1	2025-02-10 06:11:27.994699
381	6	periousity, 感觉、灼热、排泄	1	2025-02-10 06:59:34.674832
382	8	The translation of "畅" is "happy".	1	2025-02-10 06:59:41.731586
383	12	The branch located at Zhongheng Jiangang Jiangding Road,Zhongheng District, Hangzhou, China. (The Hong Kong Jinhua Jinsung Hospital and Medical Clinic Center)	1	2025-02-10 06:59:48.181029
384	13	Comprehensive National Report on Statistics, 3-21-4567890	1	2025-02-10 06:59:57.898376
385	17	Love, Jieqin. Medical Examination Report	1	2025-02-10 07:00:17.834335
386	19	Mr. Li Hui, Gender ID 2005499272. Patient number 1522206240111.	1	2025-02-10 07:00:27.513069
387	12	Jianye Nervous Medical Care Center  \n（Jianye Nanxin Guobing Jianshu Medical Operating Co., Ltd.)	1	2025-02-10 07:00:44.922322
388	13	Comprehensive and Standardized Notification on the Reading of a Comprehensive and Standardized Notification at 400-081-8899（+65 373 2889）	1	2025-02-10 07:00:57.658962
389	19	First born ⽤⼾ID 2005499272 体检号 152,220,624,011,1	1	2025-02-10 07:01:07.593241
390	57	健康体检报告  \nHealth inspections report	1	2025-02-10 07:01:16.777466
391	6	a novel or unexpected sensation, including itching, irritation, or nausea.	1	2025-02-10 07:11:47.295553
392	8	The word "畅" in Chinese usually translates to "free" or "open" in English. If you provide a specific sentence or context, I can help translate it accurately!	1	2025-02-10 07:11:58.293577
393	8	pleasing	1	2025-02-10 07:11:59.532572
394	59	Disgusted	1	2025-02-10 09:05:58.142788
395	60	Happy Fun Times!	1	2025-02-10 09:06:46.931675
\.


--
-- Data for Name: translations; Type: TABLE DATA; Schema: public; Owner: translator
--

COPY public.translations (id, source_text, confirmed_translation, is_confirmed, return_original, created_at, updated_at) FROM stdin;
56	爱康国宾	iKang	t	f	2025-02-08 15:30:21.959125	2025-02-10 02:16:16.955221
21	检查者：	Checker	t	f	2025-02-08 15:26:44.967667	2025-02-10 06:28:26.814326
16	注： ⾃费增项	Note: Additional terms	t	f	2025-02-08 15:26:15.78882	2025-02-10 06:28:34.068791
45	正常	Normal	t	f	2025-02-08 15:28:44.627666	2025-02-10 02:26:18.358768
42	心律	Cardiac Rhythm	t	f	2025-02-08 15:28:32.38917	2025-02-10 06:29:50.292983
40	心率	heart rate 	t	f	2025-02-08 15:28:17.041703	2025-02-10 02:27:46.38167
39	无特殊	Nothing special	t	f	2025-02-08 15:28:16.706589	2025-02-10 02:28:31.277942
38	家族史	Family History	t	f	2025-02-08 15:28:16.455567	2025-02-10 02:29:09.827606
37	无	None	t	f	2025-02-08 15:28:16.129934	2025-02-10 02:29:49.593083
36	病史	Disease history	t	f	2025-02-08 15:28:15.843012	2025-02-10 02:30:12.566873
8	畅。	  	t	f	2025-02-08 15:25:15.616775	2025-02-10 07:16:41.641029
5	1、慢性咽炎主要发⽣于上呼吸道感染治疗不彻底或⻓时间受刺激性⻝物或⽓体刺激的结果，常⻅咽部	1. Chronic pharyngitis mainly occurs as a result of incomplete treatment of upper respiratory tract infections or prolonged exposure to irritating foods or gases. Common symptoms include persistent discomfort in the throat.	t	f	2025-02-08 15:24:50.615618	2025-02-10 06:49:59.92942
57	健康体检报告 MEDICAL EXAMINATION REPORT	\N	t	t	2025-02-08 15:30:22.416034	2025-02-10 06:56:48.89707
55	初步意见 未见明显异常	Initial opinion：non-obvious anomalies 	t	f	2025-02-08 15:29:45.482811	2025-02-10 02:38:59.624237
54	内科其它	Mental Health Other	t	f	2025-02-08 15:29:35.014424	2025-02-10 03:28:03.033063
59	不开心	\N	f	f	2025-02-10 09:05:58.142788	2025-02-10 09:05:58.142788
19	先⽣ ⽤⼾ID 2005499272 体检号 1522206240111	\N	t	t	2025-02-08 15:26:28.794161	2025-02-10 06:57:01.450222
35	检查所见	inspect	t	f	2025-02-08 15:28:00.727921	2025-02-10 03:57:46.627904
4	02 慢性咽炎	02. Chronic Throat Inflammation	t	f	2025-02-08 15:24:42.884713	2025-02-10 03:58:01.885198
3	注意⽤眼卫⽣，请定期医院眼科复查。	Please maintain eye hygiene and regularly visit an optician to have an optical examination.	t	f	2025-02-08 15:24:33.577497	2025-02-10 03:58:19.68869
18	王海鹏	Wang Haipeng	t	f	2025-02-08 15:26:24.235821	2025-02-10 06:04:15.781314
48	肝脏触诊	Liver Tap Test	t	f	2025-02-08 15:28:56.083507	2025-02-10 06:44:19.487099
15	查看彩⾊报告	View Color Report	t	f	2025-02-08 15:26:15.461455	2025-02-10 06:04:59.517677
60	快快乐乐	\N	f	f	2025-02-10 09:06:46.931675	2025-02-10 09:06:46.931675
25	单位	Unit	t	f	2025-02-08 15:27:06.239519	2025-02-10 06:25:42.303936
23	检查项目	checks project	t	f	2025-02-08 15:26:55.844096	2025-02-10 06:26:15.335805
14	下载爱康APP	Download iKang App	t	f	2025-02-08 15:26:09.829415	2025-02-10 06:28:07.895329
41	次/分	bpm	t	f	2025-02-08 15:28:21.656579	2025-02-10 06:30:33.453866
51	脾脏肋下未触及	The spleen was not palpable below the costal margin.	t	f	2025-02-08 15:29:13.919247	2025-02-10 06:31:35.662579
10	4、症状严重、反复发作时，应去医院⽿鼻咽喉科治疗。	4、Recurring occurrences of serious symptoms should prompt a visit to the sinous and oropharyonic department.	t	f	2025-02-08 15:25:30.268033	2025-02-10 06:32:20.581837
31	收缩压	Systolic Pressure	t	f	2025-02-08 15:27:32.829651	2025-02-10 06:38:22.942649
50	脾脏触诊	hepatobiliary organs examination	t	f	2025-02-08 15:29:07.783596	2025-02-10 06:38:44.294565
22	陈素芬	Chen Xufeng	t	f	2025-02-08 15:26:55.493247	2025-02-10 06:38:55.304065
26	异常描述	abnormal description	t	f	2025-02-08 15:27:11.734815	2025-02-10 06:44:23.232004
2	01 近视眼术后	01 Postoperative Myopia Surgery	t	f	2025-02-08 15:24:29.585391	2025-02-10 06:40:26.265832
44	心音	heart sound	t	f	2025-02-08 15:28:44.376466	2025-02-10 06:41:23.381463
7	2、避免⻓时间⻝⽤刺激性⻝物及烟、酒等。常⽤淡盐⽔漱⼝，可饮⽤保健茶，多饮⽔，保持排便通	Avoid prolonged consumption of irritating foods, tobacco, alcohol, etc. Regularly rinse your mouth with light salt water, drink health tea, stay hydrated, and maintain regular bowel movements.	t	f	2025-02-08 15:25:09.743532	2025-02-10 06:44:52.777148
11	03 项韧带部分钙化；颈椎⽣理曲度变直	03.calcium accumulation in the calcaneus:narrowing of the calcaneus spine neck	t	f	2025-02-08 15:25:39.648947	2025-02-10 06:41:50.772449
32	舒张压	diastolic blood pressure	t	f	2025-02-08 15:27:40.586262	2025-02-10 06:42:32.870897
24	测量结果	Measured Results	t	f	2025-02-08 15:27:05.975754	2025-02-10 06:45:08.084817
30	体重指数	BMI	t	f	2025-02-08 15:27:32.490043	2025-02-10 06:45:28.64083
9	3、在有烟尘或刺激性⽓体环境中⼯作应戴⼝罩。	Wear a mask when working in environments with dust or irritating gases.	t	f	2025-02-08 15:25:22.781068	2025-02-10 06:43:37.153717
49	肝脏肋下未触及	The liver in the ribcage is not being pierced.	t	f	2025-02-08 15:29:00.523517	2025-02-10 06:45:39.788247
47	双侧呼吸音未闻及异常	Double respiratory sound, not heard and showing abnormal features.	t	f	2025-02-08 15:28:49.656681	2025-02-10 06:45:47.09081
28	身高	height	t	f	2025-02-08 15:27:22.419964	2025-02-10 06:48:25.297512
20	3.健康体检结果	3. Health Check-Up Results	t	f	2025-02-08 15:26:35.660232	2025-02-10 06:48:41.153496
33	初步意见	Initial assessment	t	f	2025-02-08 15:27:40.893399	2025-02-10 06:48:54.452195
1	2.专家建议与指导	2. Expert advice and guidance	t	f	2025-02-08 15:24:23.427099	2025-02-10 06:49:07.998119
13	全国统⼀报告解读专线：400-081-8899	\N	t	t	2025-02-08 15:26:01.454971	2025-02-10 06:57:07.251344
27	参考区间	Reference interval	t	f	2025-02-08 15:27:17.31963	2025-02-10 06:50:04.852971
43	齐	Regular	t	f	2025-02-08 15:28:32.642223	2025-02-10 06:50:44.249158
29	体重	weight	t	f	2025-02-08 15:27:22.66623	2025-02-10 06:50:49.42562
46	肺部听诊	Lung listening	t	f	2025-02-08 15:28:44.87511	2025-02-10 06:51:16.324731
34	未见明显异常	No obvious signs of abnormality	t	f	2025-02-08 15:27:41.150122	2025-02-10 06:51:21.916674
53	双肾区无叩痛	No pain in the double kidney area	t	f	2025-02-08 15:29:24.464139	2025-02-10 06:51:26.390737
12	杭州滨江江南⼤道分院（杭州爱康国宾江南⼤道医疗⻔诊部有限公司）	\N	t	t	2025-02-08 15:25:47.362397	2025-02-10 06:57:12.63177
17	爱康国宾 健康体检报告 MEDICAL EXAMINATION REPORT	\N	t	t	2025-02-08 15:26:16.111885	2025-02-10 06:57:44.992098
58	肾脏叩诊	 Kidney Percussio	t	f	2025-02-10 06:10:50.5097	2025-02-10 06:57:55.187732
6	异物感，⼲痒、作呕等症状。	Symptoms such as a foreign body sensation, dryness, itching, and nausea.	t	f	2025-02-08 15:24:59.180969	2025-02-10 07:12:23.837238
\.


--
-- Name: machine_translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: translator
--

SELECT pg_catalog.setval('public.machine_translations_id_seq', 395, true);


--
-- Name: translations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: translator
--

SELECT pg_catalog.setval('public.translations_id_seq', 60, true);


--
-- Name: machine_translations machine_translations_pkey; Type: CONSTRAINT; Schema: public; Owner: translator
--

ALTER TABLE ONLY public.machine_translations
    ADD CONSTRAINT machine_translations_pkey PRIMARY KEY (id);


--
-- Name: machine_translations machine_translations_translation_id_translated_text_key; Type: CONSTRAINT; Schema: public; Owner: translator
--

ALTER TABLE ONLY public.machine_translations
    ADD CONSTRAINT machine_translations_translation_id_translated_text_key UNIQUE (translation_id, translated_text);


--
-- Name: translations translations_pkey; Type: CONSTRAINT; Schema: public; Owner: translator
--

ALTER TABLE ONLY public.translations
    ADD CONSTRAINT translations_pkey PRIMARY KEY (id);


--
-- Name: machine_translations machine_translations_translation_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: translator
--

ALTER TABLE ONLY public.machine_translations
    ADD CONSTRAINT machine_translations_translation_id_fkey FOREIGN KEY (translation_id) REFERENCES public.translations(id);


--
-- PostgreSQL database dump complete
--

