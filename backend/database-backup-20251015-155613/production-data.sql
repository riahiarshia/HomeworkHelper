--
-- PostgreSQL database dump
--

\restrict afqVzj8iWZaMSDezIpVxAG1LKMjm3iSIBGI2ZJjBZRb0YbLAhfEA0mtBdRkUWZw

-- Dumped from database version 15.14
-- Dumped by pg_dump version 16.10 (Homebrew)

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

--
-- Data for Name: admin_users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.admin_users (id, username, email, password_hash, role, is_active, created_at, last_login) FROM stdin;
1	admin	support_homework@arshia.com	5dbb0b12436be7483ef1b7c765ad195dba10efa46a4ac6f736ccf614631b9bb4	super_admin	t	2025-10-06 18:37:38.495925	2025-10-15 20:43:29.455396
\.


--
-- Data for Name: device_logins; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.device_logins (id, user_id, device_id, login_time, ip_address, user_agent, device_info, created_at) FROM stdin;
1	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:02:08.787697	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:02:08.787697
2	3797d874-5599-4844-8d6d-e1958e11d82a	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:02:47.776797	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:02:47.776797
3	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:18:26.070511	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:18:26.070511
4	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:18:33.896733	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:18:33.896733
5	3797d874-5599-4844-8d6d-e1958e11d82a	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:18:50.912902	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:18:50.912902
6	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:19:02.382436	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:19:02.382436
7	3797d874-5599-4844-8d6d-e1958e11d82a	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:19:08.524433	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:19:08.524433
8	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:23:46.623848	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:23:46.623848
9	3797d874-5599-4844-8d6d-e1958e11d82a	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:24:24.500211	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:24:24.500211
10	3797d874-5599-4844-8d6d-e1958e11d82a	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:25:09.881327	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:25:09.881327
11	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:25:25.960461	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:25:25.960461
12	33bc2695-7dcf-4109-bb70-ffc6fcb958a8	test-device	2025-10-09 21:27:51.733292	::ffff:169.254.130.1	curl/8.7.1	{"appBuild": "1", "deviceId": "test-device", "platform": "iOS", "appVersion": "1.0.0", "deviceName": "Test iPhone", "deviceModel": "iPhone", "systemVersion": "18.0"}	2025-10-09 21:27:51.733292
13	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:27:51.734916	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:27:51.734916
14	610b14cb-c446-46b7-bcac-e0565e7ea5ea	test-device-123	2025-10-09 21:28:03.195719	::ffff:169.254.130.1	curl/8.7.1	{"appBuild": "1", "deviceId": "test-device-123", "platform": "iOS", "appVersion": "1.0.0", "deviceName": "Test iPhone", "deviceModel": "iPhone", "systemVersion": "18.0"}	2025-10-09 21:28:03.195719
15	3797d874-5599-4844-8d6d-e1958e11d82a	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:28:14.840881	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:28:14.840881
16	8ca1bd33-89e6-4508-92df-872fc8450ef4	unknown	2025-10-09 21:28:57.619873	::ffff:169.254.130.1	HomeworkHelper/6 CFNetwork/3826.600.41 Darwin/24.6.0	{}	2025-10-09 21:28:57.619873
17	3797d874-5599-4844-8d6d-e1958e11d82a	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 21:46:02.915458	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 21:46:02.915458
18	3797d874-5599-4844-8d6d-e1958e11d82a	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 22:34:59.04076	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 22:34:59.04076
19	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 22:53:03.736021	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 22:53:03.736021
20	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-09 23:28:10.722787	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-09 23:28:10.722787
21	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-10 02:11:30.908729	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-10 02:11:30.908729
22	81ec2385-7f7f-4db8-89b9-204d0c24a1df	unknown	2025-10-10 17:15:26.507824	::ffff:169.254.130.1	HomeworkHelper/6 CFNetwork/3826.600.41 Darwin/24.6.0	{}	2025-10-10 17:15:26.507824
23	fc06e3c3-d68e-42aa-b584-b0a59ae8c718	unknown	2025-10-10 17:35:11.048002	::ffff:169.254.130.1	HomeworkHelper/6 CFNetwork/3826.600.41 Darwin/24.6.0	{}	2025-10-10 17:35:11.048002
24	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-10 17:44:16.66498	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-10 17:44:16.66498
25	81ec2385-7f7f-4db8-89b9-204d0c24a1df	unknown	2025-10-10 17:52:42.936169	::ffff:169.254.130.1	HomeworkHelper/6 CFNetwork/3826.600.41 Darwin/24.6.0	{}	2025-10-10 17:52:42.936169
26	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	2025-10-10 17:56:03.952949	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-10 17:56:03.952949
27	f30fe78c-277e-432e-a1f6-83c4fad36837	unknown	2025-10-10 19:12:25.237441	::ffff:169.254.130.1	HomeworkHelper/6 CFNetwork/3860.100.1 Darwin/25.0.0	{}	2025-10-10 19:12:25.237441
28	f30fe78c-277e-432e-a1f6-83c4fad36837	5C075B04-25B8-4915-A49A-0E1EF0E5C6B3	2025-10-10 23:38:35.591041	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "5C075B04-25B8-4915-A49A-0E1EF0E5C6B3", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-10 23:38:35.591041
29	3797d874-5599-4844-8d6d-e1958e11d82a	5C075B04-25B8-4915-A49A-0E1EF0E5C6B3	2025-10-11 00:12:45.466793	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "5C075B04-25B8-4915-A49A-0E1EF0E5C6B3", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 00:12:45.466793
30	f30fe78c-277e-432e-a1f6-83c4fad36837	5C075B04-25B8-4915-A49A-0E1EF0E5C6B3	2025-10-11 00:48:36.261761	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "5C075B04-25B8-4915-A49A-0E1EF0E5C6B3", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 00:48:36.261761
31	3797d874-5599-4844-8d6d-e1958e11d82a	AC10B57F-4137-4F20-9C76-A7C9540F387E	2025-10-11 03:32:05.432439	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "AC10B57F-4137-4F20-9C76-A7C9540F387E", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 03:32:05.432439
32	f30fe78c-277e-432e-a1f6-83c4fad36837	7475847D-E5AC-4675-84BC-28BECB336E35	2025-10-11 04:09:19.837584	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "7475847D-E5AC-4675-84BC-28BECB336E35", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 04:09:19.837584
33	3797d874-5599-4844-8d6d-e1958e11d82a	1EC2C674-60A2-42C5-8D8E-760561CFDD32	2025-10-11 04:13:05.007224	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "1EC2C674-60A2-42C5-8D8E-760561CFDD32", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 04:13:05.007224
34	f30fe78c-277e-432e-a1f6-83c4fad36837	F877F805-6C36-4648-8024-A739638B1DFE	2025-10-11 04:24:21.729447	::ffff:169.254.130.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "F877F805-6C36-4648-8024-A739638B1DFE", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 04:24:21.729447
35	3797d874-5599-4844-8d6d-e1958e11d82a	196A465D-D76E-4029-8835-4CCCCCD38612	2025-10-11 17:42:59.530424	::ffff:169.254.130.1	HomeworkHelper/7 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "7", "deviceId": "196A465D-D76E-4029-8835-4CCCCCD38612", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 17:42:59.530424
36	f30fe78c-277e-432e-a1f6-83c4fad36837	F877F805-6C36-4648-8024-A739638B1DFE	2025-10-11 19:21:54.565275	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "F877F805-6C36-4648-8024-A739638B1DFE", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 19:21:54.565275
37	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:22:27.200392	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:22:27.200392
38	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:23:06.787313	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:23:06.787313
39	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:25:10.86041	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:25:10.86041
40	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:26:38.585424	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:26:38.585424
41	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:29:30.966168	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:29:30.966168
42	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:38:22.3629	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:38:22.3629
43	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:52:48.583747	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:52:48.583747
44	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:53:57.125922	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:53:57.125922
45	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:54:15.584119	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:54:15.584119
46	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:54:37.972963	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:54:37.972963
47	0e23b50a-77dd-43c9-a0cb-2b980c349995	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 20:55:19.295669	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 20:55:19.295669
48	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 21:50:11.805934	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 21:50:11.805934
49	db27c446-cab9-40dc-b5a3-1b9863c8437f	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-11 21:56:41.176814	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 21:56:41.176814
50	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	196A465D-D76E-4029-8835-4CCCCCD38612	2025-10-11 23:46:53.719741	::ffff:172.16.0.1	HomeworkHelper/7 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "7", "deviceId": "196A465D-D76E-4029-8835-4CCCCCD38612", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-11 23:46:53.719741
51	db27c446-cab9-40dc-b5a3-1b9863c8437f	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 01:23:22.036804	::ffff:172.16.0.1	HomeworkHelper/8 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "8", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 01:23:22.036804
52	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 01:25:42.477819	::ffff:172.16.0.1	HomeworkHelper/8 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "8", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 01:25:42.477819
53	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 01:51:15.144088	::ffff:172.16.0.1	HomeworkHelper/8 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "8", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 01:51:15.144088
54	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 02:54:53.476287	::ffff:172.16.0.1	HomeworkHelper/8 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "8", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 02:54:53.476287
55	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 02:59:52.289753	::ffff:172.16.0.1	HomeworkHelper/8 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "8", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 02:59:52.289753
56	0e23b50a-77dd-43c9-a0cb-2b980c349995	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 03:05:18.600849	::ffff:172.16.0.1	HomeworkHelper/8 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "8", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 03:05:18.600849
57	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 17:39:08.837684	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 17:39:08.837684
58	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 19:25:10.581266	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 19:25:10.581266
59	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 19:41:18.105652	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 19:41:18.105652
60	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 19:47:03.162795	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 19:47:03.162795
61	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 20:10:37.850862	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 20:10:37.850862
62	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 21:13:03.726654	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 21:13:03.726654
63	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 21:34:21.724882	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 21:34:21.724882
64	f430a463-c285-4ab3-a8d5-7fd38f0c5f85	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 21:44:41.723649	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 21:44:41.723649
65	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 21:48:49.802316	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 21:48:49.802316
66	25fa3bf5-4846-436b-afc8-8f95213a56a6	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 22:00:16.19502	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 22:00:16.19502
67	898913d2-1fa5-4da3-988b-17791953b04c	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 23:55:12.808342	::ffff:172.16.0.1	HomeworkHelper/9 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "9", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 23:55:12.808342
68	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-12 23:55:48.304791	::ffff:172.16.0.1	HomeworkHelper/9 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "9", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "1.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-12 23:55:48.304791
69	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-13 00:43:04.264849	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "20", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-13 00:43:04.264849
70	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-13 00:45:33.4894	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "20", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-13 00:45:33.4894
71	0e23b50a-77dd-43c9-a0cb-2b980c349995	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-13 00:48:26.423336	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "20", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-13 00:48:26.423336
72	898913d2-1fa5-4da3-988b-17791953b04c	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-13 17:52:59.685044	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "2.0", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-13 17:52:59.685044
73	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-13 21:59:40.567385	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-13 21:59:40.567385
74	25fa3bf5-4846-436b-afc8-8f95213a56a6	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-13 22:01:13.26414	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-13 22:01:13.26414
75	82c463e3-8349-4657-96a1-99ef136c9163	1CA248AE-2252-4F35-9C7B-310490274514	2025-10-14 04:25:04.785668	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3826.400.120 Darwin/24.3.0	{"appBuild": "1", "deviceId": "1CA248AE-2252-4F35-9C7B-310490274514", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "18.3.2"}	2025-10-14 04:25:04.785668
76	898913d2-1fa5-4da3-988b-17791953b04c	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-14 04:28:03.88611	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-14 04:28:03.88611
77	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-14 04:28:45.861902	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-14 04:28:45.861902
78	71cc27f6-5272-435c-a326-5853af953e77	7128365C-CB0B-4430-9333-6AA2CD7F5C1A	2025-10-14 17:47:21.701396	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "7128365C-CB0B-4430-9333-6AA2CD7F5C1A", "platform": "iOS", "appVersion": "3", "deviceName": "iPad", "deviceModel": "iPad", "systemVersion": "26.0.1"}	2025-10-14 17:47:21.701396
79	8511b345-0d92-4c84-95a2-9d3483c8829e	FDA2BCA6-6C1A-4681-99BC-450713EDC958	2025-10-14 21:25:09.925748	::ffff:172.16.0.1	HomeworkHelper/1 CFNetwork/3826.600.41 Darwin/24.6.0	{"appBuild": "1", "deviceId": "FDA2BCA6-6C1A-4681-99BC-450713EDC958", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "18.6.2"}	2025-10-14 21:25:09.925748
80	25fa3bf5-4846-436b-afc8-8f95213a56a6	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-14 23:25:57.330765	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-14 23:25:57.330765
81	898913d2-1fa5-4da3-988b-17791953b04c	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-14 23:26:36.39566	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-14 23:26:36.39566
82	8726319a-70fc-4e6b-8b00-d5a9f8c8e155	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-14 23:41:57.593916	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-14 23:41:57.593916
83	e64cac7b-7b6e-4609-adfd-5c648758b000	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-14 23:42:58.541858	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-14 23:42:58.541858
84	4fb71701-c436-49ab-950b-6b32b0141897	unknown	2025-10-15 00:10:50.619892	::ffff:172.16.0.1	curl/8.7.1	{}	2025-10-15 00:10:50.619892
85	25fa3bf5-4846-436b-afc8-8f95213a56a6	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-15 01:11:25.657734	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-15 01:11:25.657734
86	e64cac7b-7b6e-4609-adfd-5c648758b000	2A4BDB43-B4BB-46BD-9368-2E205BD95D08	2025-10-15 02:53:47.611622	::ffff:172.16.0.1	Homework%20HelperDev/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2A4BDB43-B4BB-46BD-9368-2E205BD95D08", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-15 02:53:47.611622
87	e64cac7b-7b6e-4609-adfd-5c648758b000	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-15 02:57:46.285499	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-15 02:57:46.285499
88	ba57e63c-23bb-44d0-99a7-052c309b5b2b	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-15 02:58:18.438859	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-15 02:58:18.438859
89	515a3b0b-5105-445b-aaa0-06c9432a01a7	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-15 02:59:36.222466	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-15 02:59:36.222466
90	0e23b50a-77dd-43c9-a0cb-2b980c349995	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-15 03:05:25.401429	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-15 03:05:25.401429
91	b1cfd676-d3dd-4979-9bef-7d79e7c36297	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	2025-10-15 03:05:51.449806	::ffff:172.16.0.1	Homework%20Helper/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2CACD9BD-47E4-4F81-8DFA-4E481AA74E86", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-15 03:05:51.449806
92	515a3b0b-5105-445b-aaa0-06c9432a01a7	2A4BDB43-B4BB-46BD-9368-2E205BD95D08	2025-10-15 22:13:49.703102	::ffff:172.16.0.1	Homework%20HelperStaging/1 CFNetwork/3860.100.1 Darwin/25.0.0	{"appBuild": "1", "deviceId": "2A4BDB43-B4BB-46BD-9368-2E205BD95D08", "platform": "iOS", "appVersion": "3", "deviceName": "iPhone", "deviceModel": "iPhone", "systemVersion": "26.0.1"}	2025-10-15 22:13:49.703102
\.


--
-- Data for Name: entitlements_ledger; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.entitlements_ledger (id, product_id, subscription_group_id, original_transaction_id_hash, ever_trial, status, first_seen_at, last_seen_at) FROM stdin;
\.


--
-- Data for Name: fraud_flags; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fraud_flags (id, user_id, device_id, reason, severity, details, resolved, resolved_at, resolved_by, created_at) FROM stdin;
1	f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-09T21:02:08.875Z"}	f	\N	\N	2025-10-09 21:02:08.892245
2	33bc2695-7dcf-4109-bb70-ffc6fcb958a8	test-device	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-09T21:27:51.827Z"}	f	\N	\N	2025-10-09 21:27:51.827765
3	610b14cb-c446-46b7-bcac-e0565e7ea5ea	test-device-123	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-09T21:28:03.224Z"}	f	\N	\N	2025-10-09 21:28:03.224633
4	8ca1bd33-89e6-4508-92df-872fc8450ef4	unknown	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-09T21:28:57.632Z"}	f	\N	\N	2025-10-09 21:28:57.63272
5	f30fe78c-277e-432e-a1f6-83c4fad36837	unknown	multiple_accounts_per_device:4	medium	{"patterns": ["multiple_accounts_per_device:4"], "timestamp": "2025-10-10T19:12:25.368Z"}	f	\N	\N	2025-10-10 19:12:25.369617
6	f30fe78c-277e-432e-a1f6-83c4fad36837	5C075B04-25B8-4915-A49A-0E1EF0E5C6B3	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-10T23:38:35.608Z"}	f	\N	\N	2025-10-10 23:38:35.609935
7	3797d874-5599-4844-8d6d-e1958e11d82a	AC10B57F-4137-4F20-9C76-A7C9540F387E	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-11T03:32:05.444Z"}	f	\N	\N	2025-10-11 03:32:05.444925
8	f30fe78c-277e-432e-a1f6-83c4fad36837	7475847D-E5AC-4675-84BC-28BECB336E35	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-11T04:09:19.871Z"}	f	\N	\N	2025-10-11 04:09:19.871858
9	3797d874-5599-4844-8d6d-e1958e11d82a	1EC2C674-60A2-42C5-8D8E-760561CFDD32	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-11T04:13:05.028Z"}	f	\N	\N	2025-10-11 04:13:05.028455
10	f30fe78c-277e-432e-a1f6-83c4fad36837	F877F805-6C36-4648-8024-A739638B1DFE	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-11T04:24:21.749Z"}	f	\N	\N	2025-10-11 04:24:21.750347
11	3797d874-5599-4844-8d6d-e1958e11d82a	196A465D-D76E-4029-8835-4CCCCCD38612	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-11T17:42:59.584Z"}	f	\N	\N	2025-10-11 17:42:59.588666
12	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-11T20:22:27.217Z"}	f	\N	\N	2025-10-11 20:22:27.222027
13	db27c446-cab9-40dc-b5a3-1b9863c8437f	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:4	medium	{"patterns": ["multiple_accounts_per_device:4"], "timestamp": "2025-10-11T21:56:41.232Z"}	f	\N	\N	2025-10-11 21:56:41.236453
14	db27c446-cab9-40dc-b5a3-1b9863c8437f	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:4	medium	{"patterns": ["multiple_accounts_per_device:4"], "timestamp": "2025-10-12T01:23:22.070Z"}	f	\N	\N	2025-10-12 01:23:22.074424
15	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T01:25:42.507Z"}	f	\N	\N	2025-10-12 01:25:42.512324
16	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T01:51:15.157Z"}	f	\N	\N	2025-10-12 01:51:15.161444
17	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T02:54:53.487Z"}	f	\N	\N	2025-10-12 02:54:53.490984
18	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T02:59:52.302Z"}	f	\N	\N	2025-10-12 02:59:52.306326
19	0e23b50a-77dd-43c9-a0cb-2b980c349995	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T03:05:18.614Z"}	f	\N	\N	2025-10-12 03:05:18.617471
20	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T17:39:08.854Z"}	f	\N	\N	2025-10-12 17:39:08.856605
21	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T19:25:10.609Z"}	f	\N	\N	2025-10-12 19:25:10.61093
22	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T19:41:18.123Z"}	f	\N	\N	2025-10-12 19:41:18.12539
23	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T19:47:03.178Z"}	f	\N	\N	2025-10-12 19:47:03.180594
24	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T20:10:37.895Z"}	f	\N	\N	2025-10-12 20:10:37.897864
25	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T21:13:03.793Z"}	f	\N	\N	2025-10-12 21:13:03.795566
26	d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-12T21:34:21.744Z"}	f	\N	\N	2025-10-12 21:34:21.746178
27	f430a463-c285-4ab3-a8d5-7fd38f0c5f85	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:6	high	{"patterns": ["excessive_accounts_per_device:6"], "timestamp": "2025-10-12T21:44:41.750Z"}	f	\N	\N	2025-10-12 21:44:41.752143
28	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:6, rapid_account_switching:4	high	{"patterns": ["excessive_accounts_per_device:6", "rapid_account_switching:4"], "timestamp": "2025-10-12T21:48:49.816Z"}	f	\N	\N	2025-10-12 21:48:49.818102
29	25fa3bf5-4846-436b-afc8-8f95213a56a6	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:7, rapid_account_switching:5	high	{"patterns": ["excessive_accounts_per_device:7", "rapid_account_switching:5"], "timestamp": "2025-10-12T22:00:16.210Z"}	f	\N	\N	2025-10-12 22:00:16.212228
30	898913d2-1fa5-4da3-988b-17791953b04c	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:8	high	{"patterns": ["excessive_accounts_per_device:8"], "timestamp": "2025-10-12T23:55:12.835Z"}	f	\N	\N	2025-10-12 23:55:12.836798
31	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-12T23:55:48.319Z"}	f	\N	\N	2025-10-12 23:55:48.321439
32	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-13T00:43:04.323Z"}	f	\N	\N	2025-10-13 00:43:04.324635
33	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-13T00:45:33.516Z"}	f	\N	\N	2025-10-13 00:45:33.517558
34	0e23b50a-77dd-43c9-a0cb-2b980c349995	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-13T00:48:26.448Z"}	f	\N	\N	2025-10-13 00:48:26.449757
35	898913d2-1fa5-4da3-988b-17791953b04c	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-13T17:52:59.753Z"}	f	\N	\N	2025-10-13 17:52:59.754434
36	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-13T21:59:40.584Z"}	f	\N	\N	2025-10-13 21:59:40.586752
37	25fa3bf5-4846-436b-afc8-8f95213a56a6	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-13T22:01:13.280Z"}	f	\N	\N	2025-10-13 22:01:13.282868
38	82c463e3-8349-4657-96a1-99ef136c9163	1CA248AE-2252-4F35-9C7B-310490274514	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-14T04:25:04.797Z"}	f	\N	\N	2025-10-14 04:25:04.800808
39	898913d2-1fa5-4da3-988b-17791953b04c	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-14T04:28:03.933Z"}	f	\N	\N	2025-10-14 04:28:03.954526
40	c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-14T04:28:45.870Z"}	f	\N	\N	2025-10-14 04:28:45.874075
41	71cc27f6-5272-435c-a326-5853af953e77	7128365C-CB0B-4430-9333-6AA2CD7F5C1A	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-14T17:47:21.768Z"}	f	\N	\N	2025-10-14 17:47:21.790312
42	8511b345-0d92-4c84-95a2-9d3483c8829e	FDA2BCA6-6C1A-4681-99BC-450713EDC958	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-14T21:25:09.989Z"}	f	\N	\N	2025-10-14 21:25:09.992591
43	25fa3bf5-4846-436b-afc8-8f95213a56a6	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-14T23:25:57.347Z"}	f	\N	\N	2025-10-14 23:25:57.349803
44	898913d2-1fa5-4da3-988b-17791953b04c	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:9	high	{"patterns": ["excessive_accounts_per_device:9"], "timestamp": "2025-10-14T23:26:36.419Z"}	f	\N	\N	2025-10-14 23:26:36.42131
45	8726319a-70fc-4e6b-8b00-d5a9f8c8e155	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:10	high	{"patterns": ["excessive_accounts_per_device:10"], "timestamp": "2025-10-14T23:41:57.607Z"}	f	\N	\N	2025-10-14 23:41:57.609484
46	e64cac7b-7b6e-4609-adfd-5c648758b000	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:11, rapid_account_switching:4	high	{"patterns": ["excessive_accounts_per_device:11", "rapid_account_switching:4"], "timestamp": "2025-10-14T23:42:58.552Z"}	f	\N	\N	2025-10-14 23:42:58.555237
47	4fb71701-c436-49ab-950b-6b32b0141897	unknown	multiple_accounts_per_device:5	medium	{"patterns": ["multiple_accounts_per_device:5"], "timestamp": "2025-10-15T00:10:50.635Z"}	f	\N	\N	2025-10-15 00:10:50.63927
48	25fa3bf5-4846-436b-afc8-8f95213a56a6	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:11	high	{"patterns": ["excessive_accounts_per_device:11"], "timestamp": "2025-10-15T01:11:25.675Z"}	f	\N	\N	2025-10-15 01:11:25.677449
49	e64cac7b-7b6e-4609-adfd-5c648758b000	2A4BDB43-B4BB-46BD-9368-2E205BD95D08	new_device_detected	low	{"patterns": ["new_device_detected"], "timestamp": "2025-10-15T02:53:47.626Z"}	f	\N	\N	2025-10-15 02:53:47.629125
50	e64cac7b-7b6e-4609-adfd-5c648758b000	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:11	high	{"patterns": ["excessive_accounts_per_device:11"], "timestamp": "2025-10-15T02:57:46.299Z"}	f	\N	\N	2025-10-15 02:57:46.30218
51	ba57e63c-23bb-44d0-99a7-052c309b5b2b	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:12	high	{"patterns": ["excessive_accounts_per_device:12"], "timestamp": "2025-10-15T02:58:18.449Z"}	f	\N	\N	2025-10-15 02:58:18.452177
52	515a3b0b-5105-445b-aaa0-06c9432a01a7	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:13	high	{"patterns": ["excessive_accounts_per_device:13"], "timestamp": "2025-10-15T02:59:36.234Z"}	f	\N	\N	2025-10-15 02:59:36.236754
53	0e23b50a-77dd-43c9-a0cb-2b980c349995	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:13, rapid_account_switching:4	high	{"patterns": ["excessive_accounts_per_device:13", "rapid_account_switching:4"], "timestamp": "2025-10-15T03:05:25.416Z"}	f	\N	\N	2025-10-15 03:05:25.418713
54	b1cfd676-d3dd-4979-9bef-7d79e7c36297	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	excessive_accounts_per_device:14, rapid_account_switching:5	high	{"patterns": ["excessive_accounts_per_device:14", "rapid_account_switching:5"], "timestamp": "2025-10-15T03:05:51.475Z"}	f	\N	\N	2025-10-15 03:05:51.477498
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (id, user_id, email, username, auth_provider, subscription_status, subscription_start_date, subscription_end_date, trial_started_at, promo_code_used, promo_activated_at, stripe_customer_id, stripe_subscription_id, is_active, is_banned, banned_reason, created_at, updated_at, last_active_at, password_hash, apple_user_id, apple_original_transaction_id, apple_product_id, apple_environment) FROM stdin;
49	71cc27f6-5272-435c-a326-5853af953e77	mms4s7p7w6@privaterelay.appleid.com	John Apple	apple	trial	2025-10-14 17:47:21.497	2025-10-21 17:47:21.497	2025-10-14 17:47:21.508668	\N	\N	\N	\N	t	f	\N	2025-10-14 17:47:21.508668	2025-10-14 17:48:16.347539	2025-10-14 17:48:16.347539	\N	000737.325cbb3409ba488e8a757b1f81da5240.1747	\N	\N	Production
35	610b14cb-c446-46b7-bcac-e0565e7ea5ea	test2@example.com	Test User 2	google	trial	2025-10-09 21:28:03.02	2025-10-16 21:28:03.02	2025-10-09 21:28:03.021143	\N	\N	\N	\N	t	f	\N	2025-10-09 21:28:03.021143	2025-10-09 21:28:03.021143	\N	\N	\N	\N	\N	Production
53	4fb71701-c436-49ab-950b-6b32b0141897	test-deployment-1760487049@example.com	Test User	google	expired	\N	\N	2025-10-15 00:10:50.516672	\N	\N	\N	\N	t	f	\N	2025-10-15 00:10:50.516672	2025-10-15 00:10:50.516672	\N	\N	\N	\N	\N	Production
47	3eb9d3cc-595d-402c-96ed-45439528954f	apple@arshia.com	apple@arshia.com	email	trial	2025-10-13 20:55:44.714	2025-11-12 20:55:44.714	2025-10-13 20:55:44.725305	\N	\N	\N	\N	t	f	\N	2025-10-13 20:55:44.725305	2025-10-14 23:25:45.791132	2025-10-14 23:25:45.791132	$2b$10$mDqR2TRnQSFnMOGHteLeluUGgJKCzQGSAdrlAwnaAcJx6VPxs63nO	\N	\N	\N	Production
26	82c463e3-8349-4657-96a1-99ef136c9163	samipousti@gmail.com	Sami Pousti	google	expired	2025-10-09 01:58:46.847	2025-10-14 01:58:46.847	2025-10-09 01:58:46.848731	\N	\N	\N	\N	t	f	\N	2025-10-09 01:58:46.848731	2025-10-15 02:35:41.406034	2025-10-15 02:35:41.406034	\N	\N	\N	\N	Production
27	f99ca211-365b-4127-8958-350920e0ade0	parmidaamani@gmail.com	Parmida Amani	apple	trial	2025-10-09 02:47:19.575	2025-10-16 02:47:19.581	2025-10-09 02:47:19.671914	\N	\N	\N	\N	t	f	\N	2025-10-09 02:47:19.671914	2025-10-14 17:45:12.462921	2025-10-14 17:45:12.462921	\N	001116.68eed47adbd048439e62f4841f679b5d.0247	\N	\N	Production
28	1c8e4891-b32b-4cc0-b104-b99607e8afa7	ryan.smitty@gmail.com	Ryan Smith	google	trial	2025-10-09 04:14:37.589	2025-10-16 04:14:37.589	2025-10-09 04:14:37.595939	\N	\N	\N	\N	t	f	\N	2025-10-09 04:14:37.595939	2025-10-09 04:14:37.865271	2025-10-09 04:14:37.865271	\N	\N	\N	\N	Production
55	515a3b0b-5105-445b-aaa0-06c9432a01a7	riahiarshia@gmail.com	Arshia Riahi	google	expired	\N	\N	2025-10-15 02:59:36.15563	\N	\N	\N	\N	t	f	\N	2025-10-15 02:59:36.15563	2025-10-15 22:41:18.984546	2025-10-15 22:41:18.984546	\N	\N	\N	\N	Production
34	33bc2695-7dcf-4109-bb70-ffc6fcb958a8	test@example.com	Test User	google	trial	2025-10-09 21:27:51.434	2025-10-16 21:27:51.434	2025-10-09 21:27:51.435695	\N	\N	\N	\N	t	f	\N	2025-10-09 21:27:51.435695	2025-10-09 21:27:51.435695	\N	\N	\N	\N	\N	Production
50	8511b345-0d92-4c84-95a2-9d3483c8829e	6z44qyvynj@privaterelay.appleid.com	John Hebert	apple	trial	2025-10-14 21:25:09.673	2025-10-27 21:25:09.673	2025-10-14 21:25:09.682169	\N	\N	\N	\N	t	f	\N	2025-10-14 21:25:09.682169	2025-10-14 21:50:10.58801	2025-10-14 21:50:10.58801	\N	000017.4766c3ce97a8491aa1acc4d15cf71bdc.2125	\N	\N	Production
56	b1cfd676-d3dd-4979-9bef-7d79e7c36297	arshia@azpcc.org	Arshia Riahi	google	expired	\N	\N	2025-10-15 03:05:51.379654	\N	\N	\N	\N	t	f	\N	2025-10-15 03:05:51.379654	2025-10-15 03:08:45.495122	2025-10-15 03:08:45.495122	\N	\N	\N	\N	Production
36	8ca1bd33-89e6-4508-92df-872fc8450ef4	002023.0db4218bcf5a4eb6af61f054fc483304.2126@privaterelay.appleid.com	Apple User	apple	expired	2025-10-09 21:28:57.561	2025-10-09 21:28:57.561	2025-10-09 21:28:57.561877	\N	\N	\N	\N	t	f	\N	2025-10-09 21:28:57.561877	2025-10-14 16:43:22.722806	2025-10-14 16:43:22.722806	\N	002023.0db4218bcf5a4eb6af61f054fc483304.2126	\N	\N	Production
37	81ec2385-7f7f-4db8-89b9-204d0c24a1df	rd6zmwd4qd@privaterelay.appleid.com	Sina Hajeb	apple	expired	2025-10-10 17:15:26.353	2025-10-10 17:15:26.353	2025-10-10 17:15:26.357765	\N	\N	\N	\N	t	f	\N	2025-10-10 17:15:26.357765	2025-10-12 08:03:27.028866	2025-10-12 08:03:27.028866	\N	001163.33a6faa9ac5046c9801e42196ba4a706.1715	\N	\N	Production
48	f6b7a96c-0c43-4b54-b25f-c419070bd59e	tt@arshia.com	tt@arshia.com	email	active	2025-10-13 21:09:48.047	2025-11-13 21:58:48	2025-10-13 21:09:48.048734	\N	\N	\N	\N	t	f	\N	2025-10-13 21:09:48.048734	2025-10-13 21:59:23.618151	2025-10-13 21:59:23.618151	$2b$10$dq6zvnhOoRXZZELh8esPn.vVQ.7X4dSnixbrLPHRGBWKfsuxXXcTq	\N	\N	\N	Production
38	fc06e3c3-d68e-42aa-b584-b0a59ae8c718	sinaha10@gmail.com	Sina Hajeb	google	trial	2025-10-10 17:35:10.94	2025-10-17 17:35:10.94	2025-10-10 17:35:10.94331	\N	\N	\N	\N	t	f	\N	2025-10-10 17:35:10.94331	2025-10-12 21:18:01.202564	2025-10-12 21:18:01.202564	\N	\N	\N	\N	Production
46	c21dc002-5828-4cd6-b414-4ef55a6d8e31	vpnadmaz@gmail.com	vpn admin	google	trial	2025-10-12 23:55:48.242	2025-10-19 23:55:48.242	2025-10-12 23:55:48.244418	\N	\N	\N	\N	t	f	\N	2025-10-12 23:55:48.244418	2025-10-14 21:50:06.734902	2025-10-14 21:50:06.734902	\N	\N	\N	\N	Production
44	25fa3bf5-4846-436b-afc8-8f95213a56a6	000757.afd07240d1514dfaa8b019bb4f89d2fe.2209@privaterelay.appleid.com		apple	active	2025-10-12 22:00:16.105	2025-11-13 21:58:48	2025-10-12 22:00:16.10752	\N	\N	\N	\N	t	f	\N	2025-10-12 22:00:16.10752	2025-10-15 02:57:34.649944	2025-10-15 02:57:34.649944	\N	000757.afd07240d1514dfaa8b019bb4f89d2fe.2209	\N	\N	Production
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_tokens (id, user_id, token, expires_at, created_at, used, used_at) FROM stdin;
\.


--
-- Data for Name: promo_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promo_codes (id, code, duration_days, uses_total, uses_remaining, used_count, active, starts_at, expires_at, created_by, description, created_at) FROM stdin;
1	WELCOME2025	90	100	100	0	t	\N	\N	admin	Welcome promo - 3 months free	2025-10-06 18:37:38.562845
3	EARLYBIRD	180	20	20	0	t	\N	\N	admin	Early adopters - 6 months	2025-10-06 18:37:38.562845
2	STUDENT50	30	50	50	0	t	\N	\N	admin	Student discount - 1 month	2025-10-06 18:37:38.562845
\.


--
-- Data for Name: promo_code_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.promo_code_usage (id, promo_code_id, user_id, activated_at, ip_address) FROM stdin;
\.


--
-- Data for Name: subscription_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subscription_history (id, user_id, event_type, old_status, new_status, old_end_date, new_end_date, metadata, created_at) FROM stdin;
69	25fa3bf5-4846-436b-afc8-8f95213a56a6	trial_started	\N	trial	\N	2025-10-19 22:00:16.105	\N	2025-10-12 22:00:16.113526
71	c21dc002-5828-4cd6-b414-4ef55a6d8e31	trial_started	\N	trial	\N	2025-10-19 23:55:48.242	\N	2025-10-12 23:55:48.250391
72	3eb9d3cc-595d-402c-96ed-45439528954f	user_created_by_admin	\N	\N	\N	\N	{"admin": "admin"}	2025-10-13 20:55:44.736664
73	f6b7a96c-0c43-4b54-b25f-c419070bd59e	trial_started	\N	trial	\N	2025-10-20 21:09:48.047	\N	2025-10-13 21:09:48.053175
74	71cc27f6-5272-435c-a326-5853af953e77	trial_started	\N	trial	\N	2025-10-21 17:47:21.497	\N	2025-10-14 17:47:21.514646
75	8511b345-0d92-4c84-95a2-9d3483c8829e	trial_started	\N	trial	\N	2025-10-21 21:25:09.673	\N	2025-10-14 21:25:09.691226
78	4fb71701-c436-49ab-950b-6b32b0141897	account_created	\N	expired	\N	\N	\N	2025-10-15 00:10:50.533901
80	515a3b0b-5105-445b-aaa0-06c9432a01a7	account_created	\N	expired	\N	\N	\N	2025-10-15 02:59:36.160265
81	b1cfd676-d3dd-4979-9bef-7d79e7c36297	account_created	\N	expired	\N	\N	\N	2025-10-15 03:05:51.386706
47	82c463e3-8349-4657-96a1-99ef136c9163	trial_started	\N	trial	\N	2025-10-16 01:58:46.847	\N	2025-10-09 01:58:46.853282
48	f99ca211-365b-4127-8958-350920e0ade0	trial_started	\N	trial	\N	2025-10-16 02:47:19.581	\N	2025-10-09 02:47:19.689196
49	82c463e3-8349-4657-96a1-99ef136c9163	subscription_extended	\N	\N	\N	\N	{"admin": "admin", "days_added": 30}	2025-10-09 03:31:19.468399
50	82c463e3-8349-4657-96a1-99ef136c9163	subscription_extended	\N	\N	\N	\N	{"admin": "admin", "days_added": 90}	2025-10-09 03:32:32.2323
51	82c463e3-8349-4657-96a1-99ef136c9163	access_toggled	\N	\N	\N	\N	{"admin": "admin", "is_active": false}	2025-10-09 03:33:09.775153
52	82c463e3-8349-4657-96a1-99ef136c9163	access_toggled	\N	\N	\N	\N	{"admin": "admin", "is_active": true}	2025-10-09 03:34:01.304583
53	1c8e4891-b32b-4cc0-b104-b99607e8afa7	trial_started	\N	trial	\N	2025-10-16 04:14:37.589	\N	2025-10-09 04:14:37.601199
59	33bc2695-7dcf-4109-bb70-ffc6fcb958a8	trial_started	\N	trial	\N	2025-10-16 21:27:51.434	\N	2025-10-09 21:27:51.443147
60	610b14cb-c446-46b7-bcac-e0565e7ea5ea	trial_started	\N	trial	\N	2025-10-16 21:28:03.02	\N	2025-10-09 21:28:03.04006
61	8ca1bd33-89e6-4508-92df-872fc8450ef4	trial_started	\N	trial	\N	2025-10-16 21:28:57.561	\N	2025-10-09 21:28:57.567071
62	81ec2385-7f7f-4db8-89b9-204d0c24a1df	trial_started	\N	trial	\N	2025-10-17 17:15:26.353	\N	2025-10-10 17:15:26.36886
63	fc06e3c3-d68e-42aa-b584-b0a59ae8c718	trial_started	\N	trial	\N	2025-10-17 17:35:10.94	\N	2025-10-10 17:35:10.951236
\.


--
-- Data for Name: trial_usage_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.trial_usage_history (id, original_transaction_id, user_id, apple_product_id, had_intro_offer, had_free_trial, trial_start_date, trial_end_date, apple_environment, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: user_api_usage; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_api_usage (id, user_id, endpoint, model, prompt_tokens, completion_tokens, total_tokens, cost_usd, problem_id, session_id, metadata, created_at, device_id) FROM stdin;
1	3797	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 88716, "mimeType": "image/jpeg"}	2025-10-11 18:58:09.958264	\N
2	3797	analyze_homework	gpt-4.1-mini	3503	358	3861	0.012338	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-11 18:58:17.214702	\N
3	3797d874-5599-4844-8d6d-e1958e11d82a	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 249553, "mimeType": "image/jpeg"}	2025-10-11 19:20:16.813466	\N
4	3797d874-5599-4844-8d6d-e1958e11d82a	analyze_homework	gpt-4.1-mini	3503	657	4160	0.015328	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-11 19:20:34.18839	\N
5	3797d874-5599-4844-8d6d-e1958e11d82a	generate_hint	gpt-4.1-mini	790	54	844	0.002515	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Is a map flat or round?"}	2025-10-11 19:20:36.180026	\N
6	3797d874-5599-4844-8d6d-e1958e11d82a	generate_hint	gpt-4.1-mini	832	82	914	0.002900	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Is a map flat or round?"}	2025-10-11 19:20:55.490508	\N
7	3797d874-5599-4844-8d6d-e1958e11d82a	generate_hint	gpt-4.1-mini	855	77	932	0.002908	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: What kind of view does a map give us?"}	2025-10-11 19:21:00.889367	\N
8	f30fe78c-277e-432e-a1f6-83c4fad36837	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 88716, "mimeType": "image/jpeg"}	2025-10-11 19:22:24.714954	\N
9	f30fe78c-277e-432e-a1f6-83c4fad36837	analyze_homework	gpt-4.1-mini	3503	362	3865	0.012378	\N	\N	{"gradeLevel": "11th grade", "problemText": null}	2025-10-11 19:22:30.091331	\N
10	f30fe78c-277e-432e-a1f6-83c4fad36837	generate_hint	gpt-4.1-mini	795	47	842	0.002458	\N	\N	{"gradeLevel": "11th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-11 19:22:31.699924	\N
11	f30fe78c-277e-432e-a1f6-83c4fad36837	generate_hint	gpt-4.1-mini	871	72	943	0.002898	\N	\N	{"gradeLevel": "11th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-11 19:23:03.550541	\N
12	f30fe78c-277e-432e-a1f6-83c4fad36837	chat_response	gpt-4.1-mini	236	89	325	0.001480	\N	\N	{"gradeLevel": "11th grade", "messageCount": 1}	2025-10-11 19:23:20.957472	\N
13	f30fe78c-277e-432e-a1f6-83c4fad36837	generate_hint	gpt-4.1-mini	837	66	903	0.002753	\N	\N	{"gradeLevel": "11th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-11 19:29:40.70089	\N
14	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 231336, "mimeType": "image/jpeg"}	2025-10-11 20:24:13.885523	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
15	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	3503	430	3933	0.013058	\N	\N	{"gradeLevel": "10th grade", "problemText": null}	2025-10-11 20:24:22.216369	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
16	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	794	62	856	0.002605	\N	\N	{"gradeLevel": "10th grade", "stepQuestion": "Problem 1: Is a map flat or round?"}	2025-10-11 20:24:23.9279	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
17	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 88716, "mimeType": "image/jpeg"}	2025-10-11 20:25:31.471885	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
18	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	3503	366	3869	0.012418	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-11 20:25:39.388575	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
19	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	795	53	848	0.002518	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-11 20:25:41.216199	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
20	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 88716, "mimeType": "image/jpeg"}	2025-10-11 20:30:10.194483	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
21	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	3503	345	3848	0.012208	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-11 20:30:16.505265	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
22	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	787	53	840	0.002498	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-11 20:30:17.792314	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
23	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 88716, "mimeType": "image/jpeg"}	2025-10-11 20:53:36.241	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
24	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	3503	355	3858	0.012308	\N	\N	{"gradeLevel": "7th grade", "problemText": null}	2025-10-11 20:53:42.811592	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
25	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	795	50	845	0.002488	\N	\N	{"gradeLevel": "7th grade", "stepQuestion": "Problem 1: What change of state happens to ice cream in the summer?"}	2025-10-11 20:53:44.338472	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
29	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	2624	127	2751	0.007830	\N	\N	{"fileSize": 562402, "mimeType": "image/jpeg"}	2025-10-11 21:50:46.690939	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
30	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	4193	82	4275	0.011303	\N	\N	{"gradeLevel": "9th grade", "problemText": null}	2025-10-11 21:50:50.296127	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
31	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	4193	38	4231	0.010863	\N	\N	{"gradeLevel": "9th grade", "problemText": null}	2025-10-11 21:50:52.944051	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
32	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 88716, "mimeType": "image/jpeg"}	2025-10-11 21:51:15.72019	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
33	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	3503	365	3868	0.012408	\N	\N	{"gradeLevel": "9th grade", "problemText": null}	2025-10-11 21:51:21.437061	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
34	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	795	49	844	0.002478	\N	\N	{"gradeLevel": "9th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-11 21:51:23.17216	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
35	d4050ff7-da76-4a37-a1f6-585bbeda199d	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 88716, "mimeType": "image/jpeg"}	2025-10-12 01:39:59.642927	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
36	d4050ff7-da76-4a37-a1f6-585bbeda199d	analyze_homework	gpt-4.1-mini	3503	354	3857	0.012298	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 01:40:07.984874	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
37	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	793	46	839	0.002443	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-12 01:40:09.102705	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
38	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	869	60	929	0.002773	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-12 01:40:33.045371	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
39	d4050ff7-da76-4a37-a1f6-585bbeda199d	validate_image	gpt-4.1-mini	2713	30	2743	0.007083	\N	\N	{"fileSize": 129262, "mimeType": "image/jpeg"}	2025-10-12 02:53:10.123109	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
40	d4050ff7-da76-4a37-a1f6-585bbeda199d	analyze_homework	gpt-4.1-mini	4282	509	4791	0.015795	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 02:53:18.44328	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
41	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	789	58	847	0.002553	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-12 02:53:19.687783	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
42	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	865	50	915	0.002663	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-12 02:53:30.268969	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
43	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	821	60	881	0.002653	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Water boiling."}	2025-10-12 02:53:37.313072	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
44	d4050ff7-da76-4a37-a1f6-585bbeda199d	chat_response	gpt-4.1-mini	233	94	327	0.001523	\N	\N	{"gradeLevel": "4th grade", "messageCount": 1}	2025-10-12 02:53:51.116513	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
45	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	862	67	929	0.002825	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 3: Lava turns into rock."}	2025-10-12 02:54:04.224759	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
46	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	789	57	846	0.002543	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-12 02:54:19.237596	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
47	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	2716	165	2881	0.008440	\N	\N	{"fileSize": 282264, "mimeType": "image/jpeg"}	2025-10-12 03:01:13.047436	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
48	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	4285	514	4799	0.015853	\N	\N	{"gradeLevel": "5th grade", "problemText": null}	2025-10-12 03:01:22.296218	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
49	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	791	65	856	0.002628	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What change of state happens when ice cream melts in the summer?"}	2025-10-12 03:01:24.195608	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
50	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	867	65	932	0.002818	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What change of state happens when ice cream melts in the summer?"}	2025-10-12 03:02:06.758188	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
51	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	chat_response	gpt-4.1-mini	239	82	321	0.001418	\N	\N	{"gradeLevel": "5th grade", "messageCount": 1}	2025-10-12 03:02:39.615121	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
52	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	833	45	878	0.002533	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What change of state happens when ice cream melts in the summer?"}	2025-10-12 03:02:55.057337	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
53	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	839	72	911	0.002818	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 2: What change of state happens when water boils?"}	2025-10-12 03:03:09.261686	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
54	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	791	59	850	0.002568	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What change of state happens when ice cream melts in the summer?"}	2025-10-12 03:03:53.140577	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
153	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	2561	30	2591	0.006703	\N	\N	{"fileSize": 124361, "mimeType": "image/jpeg"}	2025-10-12 17:56:26.206594	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
147	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	2561	30	2591	0.006703	\N	\N	{"fileSize": 124361, "mimeType": "image/jpeg"}	2025-10-12 17:39:24.09756	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
148	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	4130	392	4522	0.014245	\N	\N	{"gradeLevel": "7th grade", "problemText": null}	2025-10-12 17:39:30.862426	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
149	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	802	85	887	0.002855	\N	\N	{"gradeLevel": "7th grade", "stepQuestion": "Problem 1: What is the height of one cup?"}	2025-10-12 17:39:34.187332	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
150	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	850	80	930	0.002925	\N	\N	{"gradeLevel": "7th grade", "stepQuestion": "Problem 1: How many cups are stacked to make 34 cm height?"}	2025-10-12 17:40:02.13286	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
151	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	978	92	1070	0.003365	\N	\N	{"gradeLevel": "7th grade", "stepQuestion": "Problem 1: Calculate the height of one cup using the total height of 5 stacked cups (34 cm) and the height of 2 stacked cups (19 cm)."}	2025-10-12 17:40:10.060273	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
152	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	1016	64	1080	0.003180	\N	\N	{"gradeLevel": "7th grade", "stepQuestion": "Problem 1: What is the height of the single cup shown on the right?"}	2025-10-12 17:40:55.588771	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
154	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	4130	520	4650	0.015525	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 17:56:35.439154	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
155	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	796	50	846	0.002490	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup?"}	2025-10-12 17:56:36.730356	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
156	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	918	83	1001	0.003125	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: How do we calculate the height of one cup from the stack of 5 cups measuring 34 cm?"}	2025-10-12 17:56:54.14126	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
157	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	962	94	1056	0.003345	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Calculate the height of one cup using the formula 34 cm ÷ (5 - 1)."}	2025-10-12 17:57:31.482933	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
158	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	1050	79	1129	0.003415	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Verify the height of one cup using the stack of 2 cups measuring 19 cm."}	2025-10-12 17:57:39.711974	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
159	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	1092	88	1180	0.003610	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Verify the height of one cup using the stack of 2 cups measuring 19 cm."}	2025-10-12 17:57:47.051536	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
160	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	1092	82	1174	0.003550	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Verify the height of one cup using the stack of 2 cups measuring 19 cm."}	2025-10-12 17:57:51.328794	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
161	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	1104	75	1179	0.003510	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of the single cup shown with a question mark?"}	2025-10-12 17:57:58.053144	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
162	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	2561	30	2591	0.006703	\N	\N	{"fileSize": 124361, "mimeType": "image/jpeg"}	2025-10-12 18:11:00.469838	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
163	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	4130	544	4674	0.015765	\N	\N	{"gradeLevel": "10th grade", "problemText": null}	2025-10-12 18:11:09.539539	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
164	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	802	81	883	0.002815	\N	\N	{"gradeLevel": "10th grade", "stepQuestion": "Problem 1: What is the height of one cup?"}	2025-10-12 18:11:11.605239	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
165	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	940	73	1013	0.003080	\N	\N	{"gradeLevel": "10th grade", "stepQuestion": "Problem 1: How do we calculate the height of one cup from the stack of 5 cups measuring 34 cm?"}	2025-10-12 18:11:26.494115	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
166	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	971	90	1061	0.003328	\N	\N	{"gradeLevel": "10th grade", "stepQuestion": "Problem 1: Calculate the approximate height of one cup by dividing 34 cm by 5."}	2025-10-12 18:11:37.697854	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
167	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	1044	156	1200	0.004170	\N	\N	{"gradeLevel": "10th grade", "stepQuestion": "Problem 2: Given the height of 2 stacked cups is 19 cm, what is the height of one cup?"}	2025-10-12 18:11:43.847353	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
168	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	1094	110	1204	0.003835	\N	\N	{"gradeLevel": "10th grade", "stepQuestion": "Problem 3: What is the height of a single cup shown alone with a question mark?"}	2025-10-12 18:11:52.67779	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
169	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	2561	124	2685	0.007643	\N	\N	{"fileSize": 124361, "mimeType": "image/jpeg"}	2025-10-12 18:20:30.502471	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
170	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	4130	498	4628	0.015305	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 18:20:40.004769	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
171	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	4130	476	4606	0.015085	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 18:20:40.986786	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
172	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	802	68	870	0.002685	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup?"}	2025-10-12 18:20:42.475349	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
173	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	845	93	938	0.000183	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: How many cups are stacked to reach 34 cm?"}	2025-10-12 18:20:59.027515	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
174	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	952	90	1042	0.000197	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: How do we calculate the height of one cup using the total height of 5 stacked cups?"}	2025-10-12 18:21:05.775755	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
175	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	1004	71	1075	0.000193	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 2 stacked cups measure 19 cm?"}	2025-10-12 18:21:22.441967	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
176	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	1046	106	1152	0.000221	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 2 stacked cups measure 19 cm?"}	2025-10-12 18:21:29.365751	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
177	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	1046	106	1152	0.000221	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 2 stacked cups measure 19 cm?"}	2025-10-12 18:22:34.549001	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
178	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	1046	105	1151	0.000220	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 2 stacked cups measure 19 cm?"}	2025-10-12 18:23:12.14163	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
179	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	1046	115	1161	0.000226	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 2 stacked cups measure 19 cm?"}	2025-10-12 18:23:18.029007	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
180	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	1058	87	1145	0.000211	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of the single cup shown with a question mark?"}	2025-10-12 18:23:29.691336	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
181	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4o-mini	25815	30	25845	0.003890	\N	\N	{"fileSize": 124361, "mimeType": "image/jpeg"}	2025-10-12 18:31:56.054326	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
182	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4o-mini	27267	487	27754	0.004382	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 18:32:13.149849	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
183	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	822	79	901	0.000171	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 5 cups stacked together measure 34 cm?"}	2025-10-12 18:32:18.357802	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
184	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	864	71	935	0.000172	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 5 cups stacked together measure 34 cm?"}	2025-10-12 18:32:55.538095	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
185	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	864	82	946	0.000179	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 5 cups stacked together measure 34 cm?"}	2025-10-12 18:33:00.427258	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
186	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	864	89	953	0.000183	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 5 cups stacked together measure 34 cm?"}	2025-10-12 18:33:05.116477	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
187	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	864	87	951	0.000182	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 5 cups stacked together measure 34 cm?"}	2025-10-12 18:33:11.023603	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
188	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	864	129	993	0.000207	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 5 cups stacked together measure 34 cm?"}	2025-10-12 18:33:52.863683	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
189	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	chat_response	gpt-4o-mini	1840	309	2149	0.000461	\N	\N	{"gradeLevel": "4th grade", "messageCount": 1}	2025-10-12 18:34:11.685769	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
190	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	880	111	991	0.000199	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Calculate the height of one cup using the equation 5h = 34 cm."}	2025-10-12 18:35:46.799738	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
191	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	968	85	1053	0.000196	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: What is the height of 2 cups stacked together if they measure 19 cm?"}	2025-10-12 18:35:53.762553	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
192	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	1018	81	1099	0.000201	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Calculate the height of one cup using the equation 2h = 19 cm."}	2025-10-12 18:36:00.367784	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
193	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	1090	60	1150	0.000200	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 3: If we know the height of one cup, how can we find the height of 3 cups?"}	2025-10-12 18:36:08.939726	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
194	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	chat_response	gpt-4o-mini	1829	181	2010	0.000383	\N	\N	{"gradeLevel": "4th grade", "messageCount": 1}	2025-10-12 18:36:50.651663	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
195	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4o-mini	25815	30	25845	0.003890	\N	\N	{"fileSize": 124361, "mimeType": "image/jpeg"}	2025-10-12 18:41:12.722043	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
196	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4o-mini	27267	529	27796	0.004407	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 18:41:24.277505	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
197	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o-mini	826	87	913	0.000176	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the height of one cup if 5 cups stack to 34 cm?"}	2025-10-12 18:41:28.496729	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
198	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	906	92	998	0.003185	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: How do we calculate the height of one cup?"}	2025-10-12 18:41:51.89692	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
199	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	948	127	1075	0.003640	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: How do we calculate the height of one cup?"}	2025-10-12 18:42:17.091865	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
200	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	944	78	1022	0.003140	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: What is the height of 2 cups if they stack to 19 cm?"}	2025-10-12 18:42:24.187114	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
201	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	1046	77	1123	0.003385	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: How do we calculate the height of one cup from 2 cups?"}	2025-10-12 18:42:30.013041	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
202	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	1070	116	1186	0.003835	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 3: What is the height of one cup based on the previous calculations?"}	2025-10-12 18:42:38.748363	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
203	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	1112	149	1261	0.004270	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 3: What is the height of one cup based on the previous calculations?"}	2025-10-12 18:42:44.875087	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
204	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	1112	131	1243	0.004090	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 3: What is the height of one cup based on the previous calculations?"}	2025-10-12 18:47:09.301138	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
205	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4o	1419	30	1449	0.003848	\N	\N	{"fileSize": 88716, "mimeType": "image/jpeg"}	2025-10-12 18:48:28.324472	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
206	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4o	2639	345	2984	0.010048	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 18:48:39.324404	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
207	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	788	56	844	0.002530	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What change of state occurs when ice cream melts in the summer?"}	2025-10-12 18:48:40.900192	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
208	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	830	73	903	0.002805	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What change of state occurs when ice cream melts in the summer?"}	2025-10-12 18:48:44.745233	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
209	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4o	837	71	908	0.002803	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: What change of state occurs when water boils?"}	2025-10-12 18:48:50.172447	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
210	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4o-mini	25815	30	25845	0.003890	\N	\N	{"fileSize": 124361, "mimeType": "image/jpeg"}	2025-10-12 19:21:40.533347	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
211	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	validate_image	gpt-4.1-mini	2561	30	2591	0.006703	\N	\N	{"fileSize": 124361, "mimeType": "image/jpeg"}	2025-10-12 19:22:54.969626	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
212	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	analyze_homework	gpt-4.1-mini	4130	507	4637	0.015395	\N	\N	{"gradeLevel": "College - Freshman", "problemText": null}	2025-10-12 19:23:02.765576	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
213	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	798	79	877	0.002785	\N	\N	{"gradeLevel": "College - Freshman", "stepQuestion": "Problem 1: What is the height of one cup?"}	2025-10-12 19:23:04.872653	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
214	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	843	97	940	0.003078	\N	\N	{"gradeLevel": "College - Freshman", "stepQuestion": "Problem 1: How many cups are stacked to reach 34 cm?"}	2025-10-12 19:23:09.991761	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
215	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	942	83	1025	0.003185	\N	\N	{"gradeLevel": "College - Freshman", "stepQuestion": "Problem 1: How to calculate the height of one cup from the stack of 5 cups measuring 34 cm?"}	2025-10-12 19:23:15.67796	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
216	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	982	97	1079	0.003425	\N	\N	{"gradeLevel": "College - Freshman", "stepQuestion": "Problem 1: Calculate the height of one cup using 34 ÷ 5."}	2025-10-12 19:23:22.685662	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
217	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	1062	102	1164	0.003675	\N	\N	{"gradeLevel": "College - Freshman", "stepQuestion": "Problem 1: Verify the height of the cup using the stack of 2 cups measuring 19 cm."}	2025-10-12 19:23:27.287718	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
218	a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	generate_hint	gpt-4.1-mini	1104	67	1171	0.003430	\N	\N	{"gradeLevel": "College - Freshman", "stepQuestion": "Problem 1: Verify the height of the cup using the stack of 2 cups measuring 19 cm."}	2025-10-12 19:23:31.743557	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
219	d4050ff7-da76-4a37-a1f6-585bbeda199d	validate_image	gpt-4.1-mini	2153	112	2265	0.006503	\N	\N	{"fileSize": 94987, "mimeType": "image/jpeg"}	2025-10-12 19:36:53.699423	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
220	d4050ff7-da76-4a37-a1f6-585bbeda199d	analyze_homework	gpt-4.1-mini	3722	576	4298	0.015065	\N	\N	{"gradeLevel": "9th grade", "problemText": null}	2025-10-12 19:37:03.44354	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
221	d4050ff7-da76-4a37-a1f6-585bbeda199d	analyze_homework	gpt-4.1-mini	3722	555	4277	0.014855	\N	\N	{"gradeLevel": "9th grade", "problemText": null}	2025-10-12 19:37:04.59465	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
222	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	808	71	879	0.002730	\N	\N	{"gradeLevel": "9th grade", "stepQuestion": "Problem 1: Classify the change of state for 'Ice cream in ___ the summer.'"}	2025-10-12 19:37:05.387018	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
223	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	855	62	917	0.002758	\N	\N	{"gradeLevel": "9th grade", "stepQuestion": "Problem 2: Classify the change of state for water boiling."}	2025-10-12 19:37:11.501453	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
224	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	931	59	990	0.002918	\N	\N	{"gradeLevel": "9th grade", "stepQuestion": "Problem 2: Classify the change of state for water boiling."}	2025-10-12 19:37:15.945952	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
225	d4050ff7-da76-4a37-a1f6-585bbeda199d	validate_image	gpt-4.1-mini	2289	30	2319	0.006023	\N	\N	{"fileSize": 108662, "mimeType": "image/jpeg"}	2025-10-12 19:43:31.844249	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
226	d4050ff7-da76-4a37-a1f6-585bbeda199d	analyze_homework	gpt-4.1-mini	3858	64	3922	0.010285	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 19:43:35.40026	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
227	d4050ff7-da76-4a37-a1f6-585bbeda199d	validate_image	gpt-4.1-mini	2765	180	2945	0.008713	\N	\N	{"fileSize": 257309, "mimeType": "image/jpeg"}	2025-10-12 19:44:06.494529	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
228	d4050ff7-da76-4a37-a1f6-585bbeda199d	analyze_homework	gpt-4.1-mini	4334	534	4868	0.016175	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 19:44:14.905919	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
229	d4050ff7-da76-4a37-a1f6-585bbeda199d	generate_hint	gpt-4.1-mini	800	56	856	0.002560	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Classifying Changes of State - Ice cream in the summer."}	2025-10-12 19:44:16.678359	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
230	d4050ff7-da76-4a37-a1f6-585bbeda199d	analyze_homework	gpt-4.1-mini	4334	570	4904	0.016535	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 19:44:21.787669	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
231	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	validate_image	gpt-4.1-mini	2153	130	2283	0.006683	\N	\N	{"fileSize": 94987, "mimeType": "image/jpeg"}	2025-10-12 20:01:56.101186	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
232	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	3722	515	4237	0.014455	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 20:02:03.077705	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
233	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	786	49	835	0.002455	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-12 20:02:04.505774	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
234	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	3722	518	4240	0.014485	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 20:02:10.120691	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
235	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	validate_image	gpt-4.1-mini	1934	30	1964	0.005135	\N	\N	{"fileSize": 88716, "mimeType": "image/jpeg"}	2025-10-12 20:11:08.035176	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
236	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	3503	343	3846	0.012188	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 20:11:13.887255	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
237	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	787	52	839	0.002488	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-12 20:11:15.258885	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
238	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	validate_image	gpt-4.1-mini	2752	113	2865	0.008010	\N	\N	{"fileSize": 1348623, "mimeType": "image/jpeg"}	2025-10-12 20:12:33.944595	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
239	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	4321	363	4684	0.014433	\N	\N	{"gradeLevel": "4th grade", "problemText": null}	2025-10-12 20:12:44.447066	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
240	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	789	76	865	0.002733	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is 356 divided by 5?"}	2025-10-12 20:12:46.038097	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
241	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	validate_image	gpt-4.1-mini	2801	125	2926	0.008253	\N	\N	{"fileSize": 824067, "mimeType": "image/jpeg"}	2025-10-12 20:14:38.349215	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
242	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	4398	393	4791	0.014925	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-12 20:14:46.864517	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
243	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	788	88	876	0.002850	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is 356 multiplied by 5?"}	2025-10-12 20:14:49.034032	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
244	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	7151	636	7787	0.024238	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": true}	2025-10-12 20:14:50.992865	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
245	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	895	51	946	0.002748	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the first step in multiplying 356 by 5?"}	2025-10-12 20:15:22.350821	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
246	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	947	79	1026	0.003158	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What do we do with the 30 from the first step?"}	2025-10-12 20:15:52.921012	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
247	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	989	79	1068	0.003263	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What do we do with the 30 from the first step?"}	2025-10-12 20:16:32.051812	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
248	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	1016	81	1097	0.003350	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the next multiplication step?"}	2025-10-12 20:16:38.724711	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
249	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	1058	107	1165	0.003715	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the next multiplication step?"}	2025-10-12 20:17:51.797983	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
250	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	1085	64	1149	0.003353	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the final step to complete the multiplication?"}	2025-10-12 20:18:06.590008	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
251	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	1112	61	1173	0.003390	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the final answer to 356 x 5?"}	2025-10-12 20:18:42.149806	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
252	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	validate_image	gpt-4.1-mini	2752	123	2875	0.008110	\N	\N	{"fileSize": 1427222, "mimeType": "image/jpeg"}	2025-10-12 20:22:29.203796	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
253	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	4349	511	4860	0.015983	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-12 20:22:41.361015	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
254	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	7102	592	7694	0.023675	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": true}	2025-10-12 20:22:41.690827	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
255	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	788	82	870	0.002790	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is 356 multiplied by 5?"}	2025-10-12 20:22:43.626537	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
256	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	883	66	949	0.002868	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the first step in multiplying 356 by 5?"}	2025-10-12 20:23:02.704797	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
257	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	935	80	1015	0.003138	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What do we do with the 30 from the first multiplication?"}	2025-10-12 20:23:23.360519	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
258	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	1007	69	1076	0.003208	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply the tens digit (5) by 5 and add the carry 3."}	2025-10-12 20:24:05.347357	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
259	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	1049	86	1135	0.003483	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply the tens digit (5) by 5 and add the carry 3."}	2025-10-12 20:24:11.713275	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
260	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	1049	78	1127	0.003403	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply the tens digit (5) by 5 and add the carry 3."}	2025-10-12 20:24:22.721391	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
261	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	1045	61	1106	0.003223	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply the hundreds digit (3) by 5 and add the carry if any."}	2025-10-12 20:24:31.480183	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
262	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	1108	108	1216	0.003850	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the final answer for 356 × 5?"}	2025-10-12 20:25:50.701783	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
263	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	validate_image	gpt-4.1-mini	2801	30	2831	0.007303	\N	\N	{"fileSize": 983646, "mimeType": "image/jpeg"}	2025-10-12 20:28:22.289195	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
264	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	7151	525	7676	0.023128	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": true}	2025-10-12 20:28:34.435553	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
265	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	810	52	862	0.002545	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is the multiplication problem shown?"}	2025-10-12 20:28:36.394175	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
266	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	validate_image	gpt-4.1-mini	2752	30	2782	0.007180	\N	\N	{"fileSize": 1460159, "mimeType": "image/jpeg"}	2025-10-12 20:29:48.369239	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
267	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	7018	369	7387	0.021235	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": true}	2025-10-12 20:30:00.124912	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
268	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	790	67	857	0.002645	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply 386 by 2"}	2025-10-12 20:30:01.619901	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
269	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	866	61	927	0.002775	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply 386 by 2"}	2025-10-12 20:30:33.328858	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
270	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	832	76	908	0.002840	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply 386 by 2"}	2025-10-12 20:30:54.640361	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
271	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	827	47	874	0.002538	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply the ones place digit"}	2025-10-12 20:31:11.653217	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
272	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	871	102	973	0.003198	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply the tens place digit"}	2025-10-12 20:31:31.34943	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
273	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	909	93	1002	0.003203	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply the hundreds place digit"}	2025-10-12 20:31:43.702587	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
274	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	951	86	1037	0.003238	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply the hundreds place digit"}	2025-10-12 20:31:52.218917	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
275	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	940	83	1023	0.003180	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Add all partial products"}	2025-10-12 20:32:01.422048	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
276	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	validate_image	gpt-4.1-mini	2624	30	2654	0.006860	\N	\N	{"fileSize": 999003, "mimeType": "image/jpeg"}	2025-10-12 21:10:26.250482	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
277	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	analyze_homework	gpt-4.1-mini	4221	1159	5380	0.022143	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-12 21:10:53.876709	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
278	8cbe43e9-be23-4c9a-8b0f-de13f05432b9	generate_hint	gpt-4.1-mini	798	75	873	0.002745	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Determine the area of the rectangle."}	2025-10-12 21:10:55.632973	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
279	82c463e3-8349-4657-96a1-99ef136c9163	validate_image	gpt-4.1-mini	2668	30	2698	0.006970	\N	\N	{"fileSize": 3567833, "mimeType": "image/jpeg"}	2025-10-13 01:08:14.88113	1CA248AE-2252-4F35-9C7B-310490274514
280	82c463e3-8349-4657-96a1-99ef136c9163	analyze_homework	gpt-4.1-mini	4265	1255	5520	0.023213	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 01:08:42.706576	1CA248AE-2252-4F35-9C7B-310490274514
281	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	834	68	902	0.002765	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blanks for multiplication and division equations"}	2025-10-13 01:08:44.801507	1CA248AE-2252-4F35-9C7B-310490274514
282	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	910	86	996	0.003135	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blanks for multiplication and division equations"}	2025-10-13 01:09:38.840015	1CA248AE-2252-4F35-9C7B-310490274514
283	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	855	82	937	0.002958	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What number multiplied by 7 equals 700?"}	2025-10-13 01:10:44.666649	1CA248AE-2252-4F35-9C7B-310490274514
284	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	931	70	1001	0.003028	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What number multiplied by 7 equals 700?"}	2025-10-13 01:11:15.413761	1CA248AE-2252-4F35-9C7B-310490274514
285	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	925	109	1034	0.003403	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blank: 7,000 = _____ x 1,000"}	2025-10-13 01:11:34.093212	1CA248AE-2252-4F35-9C7B-310490274514
286	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	961	64	1025	0.003043	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blank: 10 x 6 = _____"}	2025-10-13 01:12:50.463531	1CA248AE-2252-4F35-9C7B-310490274514
287	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1025	101	1126	0.003573	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blank: _____ x 50 = 5,000"}	2025-10-13 01:13:22.675354	1CA248AE-2252-4F35-9C7B-310490274514
288	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1101	75	1176	0.003503	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blank: _____ x 50 = 5,000"}	2025-10-13 01:15:46.921969	1CA248AE-2252-4F35-9C7B-310490274514
289	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1106	78	1184	0.003545	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blanks for multiplication equations"}	2025-10-13 01:16:44.066047	1CA248AE-2252-4F35-9C7B-310490274514
290	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1129	57	1186	0.003393	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 100 x 17 = _____"}	2025-10-13 01:17:44.343284	1CA248AE-2252-4F35-9C7B-310490274514
291	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1171	77	1248	0.003698	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 100 x 17 = _____"}	2025-10-13 01:19:17.359491	1CA248AE-2252-4F35-9C7B-310490274514
292	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1183	49	1232	0.003448	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: _____ = 10 x 43"}	2025-10-13 01:19:46.251369	1CA248AE-2252-4F35-9C7B-310490274514
293	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1256	77	1333	0.003910	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 87,000 = _____ x 1,000"}	2025-10-13 01:20:14.141797	1CA248AE-2252-4F35-9C7B-310490274514
294	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1295	58	1353	0.003818	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 400 = 4 x _____"}	2025-10-13 01:20:40.919692	1CA248AE-2252-4F35-9C7B-310490274514
295	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1401	79	1480	0.004293	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 3: Birdie ran 4 hours each day for 30 days. How many hours did Birdie run altogether? Fill in the blank: Birdie ran for _____ hours altogether."}	2025-10-13 01:21:08.355715	1CA248AE-2252-4F35-9C7B-310490274514
296	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1484	85	1569	0.004560	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 4: Use unit form (tens, hundreds, thousands) to complete the equation: 3 x 4,000 = 12 _____"}	2025-10-13 01:21:46.263776	1CA248AE-2252-4F35-9C7B-310490274514
297	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1539	63	1602	0.004478	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 4: Fill in the blank: 3 times _____ is 12 thousands."}	2025-10-13 01:22:13.74905	1CA248AE-2252-4F35-9C7B-310490274514
298	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1587	88	1675	0.004848	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 4: Fill in the blank: 500 is 5 times _____"}	2025-10-13 01:22:37.782357	1CA248AE-2252-4F35-9C7B-310490274514
299	82c463e3-8349-4657-96a1-99ef136c9163	validate_image	gpt-4.1-mini	2668	30	2698	0.006970	\N	\N	{"fileSize": 3515415, "mimeType": "image/jpeg"}	2025-10-13 01:39:23.543496	1CA248AE-2252-4F35-9C7B-310490274514
300	82c463e3-8349-4657-96a1-99ef136c9163	analyze_homework	gpt-4.1-mini	4265	1334	5599	0.024003	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 01:39:53.084782	1CA248AE-2252-4F35-9C7B-310490274514
301	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	810	70	880	0.002725	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blanks for multiplication facts"}	2025-10-13 01:39:55.098597	1CA248AE-2252-4F35-9C7B-310490274514
302	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	852	73	925	0.002860	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blanks for multiplication facts"}	2025-10-13 01:40:19.855035	1CA248AE-2252-4F35-9C7B-310490274514
303	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	886	70	956	0.002915	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blanks for multiplication facts"}	2025-10-13 01:40:31.057122	1CA248AE-2252-4F35-9C7B-310490274514
304	82c463e3-8349-4657-96a1-99ef136c9163	chat_response	gpt-4.1-mini	246	87	333	0.001485	\N	\N	{"gradeLevel": "4th grade", "messageCount": 1}	2025-10-13 01:40:51.173027	1CA248AE-2252-4F35-9C7B-310490274514
305	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	849	64	913	0.002763	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What number times 7 equals 700?"}	2025-10-13 01:41:17.640897	1CA248AE-2252-4F35-9C7B-310490274514
306	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	925	69	994	0.003003	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What number times 7 equals 700?"}	2025-10-13 01:41:45.561191	1CA248AE-2252-4F35-9C7B-310490274514
307	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	918	99	1017	0.003285	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blank: 7,000 = ___ x 1,000"}	2025-10-13 01:41:55.003863	1CA248AE-2252-4F35-9C7B-310490274514
308	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	953	68	1021	0.003063	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blank: 10 x 6 = ___"}	2025-10-13 01:42:25.582653	1CA248AE-2252-4F35-9C7B-310490274514
309	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	995	73	1068	0.003218	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blank: 10 x 6 = ___"}	2025-10-13 01:42:40.215796	1CA248AE-2252-4F35-9C7B-310490274514
310	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1015	108	1123	0.003618	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blank: ___ x 50 = 5,000"}	2025-10-13 01:42:50.390223	1CA248AE-2252-4F35-9C7B-310490274514
311	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1057	170	1227	0.004343	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Fill in the blank: ___ x 50 = 5,000"}	2025-10-13 01:43:46.819391	1CA248AE-2252-4F35-9C7B-310490274514
312	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1074	122	1196	0.003905	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 4,000 = 10 x ___"}	2025-10-13 01:45:21.198148	1CA248AE-2252-4F35-9C7B-310490274514
313	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1125	52	1177	0.003333	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 100 x 17 = ___"}	2025-10-13 01:46:27.220296	1CA248AE-2252-4F35-9C7B-310490274514
314	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1176	51	1227	0.003450	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: ___ = 10 x 43"}	2025-10-13 01:47:00.806179	1CA248AE-2252-4F35-9C7B-310490274514
315	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1218	63	1281	0.003675	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: ___ = 10 x 43"}	2025-10-13 01:47:14.577016	1CA248AE-2252-4F35-9C7B-310490274514
316	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1246	80	1326	0.003915	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 87,000 = ___ x 1,000"}	2025-10-13 01:47:23.314063	1CA248AE-2252-4F35-9C7B-310490274514
317	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1288	72	1360	0.003940	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 87,000 = ___ x 1,000"}	2025-10-13 01:47:31.784363	1CA248AE-2252-4F35-9C7B-310490274514
318	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1288	76	1364	0.003980	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 87,000 = ___ x 1,000"}	2025-10-13 01:47:42.280159	1CA248AE-2252-4F35-9C7B-310490274514
319	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1287	72	1359	0.003938	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: Fill in the blank: 400 = 4 x ___"}	2025-10-13 01:47:48.814353	1CA248AE-2252-4F35-9C7B-310490274514
343	82c463e3-8349-4657-96a1-99ef136c9163	validate_image	gpt-4.1-mini	2716	160	2876	0.008390	\N	\N	{"fileSize": 280097, "mimeType": "image/jpeg"}	2025-10-13 18:15:05.26001	1CA248AE-2252-4F35-9C7B-310490274514
344	82c463e3-8349-4657-96a1-99ef136c9163	analyze_homework	gpt-4.1-mini	4313	513	4826	0.015913	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 18:15:14.035349	1CA248AE-2252-4F35-9C7B-310490274514
345	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	789	60	849	0.002573	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What change of state happens to ice cream in the summer?"}	2025-10-13 18:15:15.522498	1CA248AE-2252-4F35-9C7B-310490274514
346	82c463e3-8349-4657-96a1-99ef136c9163	analyze_homework	gpt-4.1-mini	4313	515	4828	0.015933	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 18:15:16.886696	1CA248AE-2252-4F35-9C7B-310490274514
347	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	865	58	923	0.002743	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What change of state happens to ice cream in the summer?"}	2025-10-13 18:15:35.779207	1CA248AE-2252-4F35-9C7B-310490274514
348	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	839	71	910	0.002808	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: What change of state happens when water boils?"}	2025-10-13 18:15:50.768751	1CA248AE-2252-4F35-9C7B-310490274514
349	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	915	57	972	0.002858	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: What change of state happens when water boils?"}	2025-10-13 18:16:29.686941	1CA248AE-2252-4F35-9C7B-310490274514
350	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	888	78	966	0.003000	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 3: What change of state happens when lava turns into rock?"}	2025-10-13 18:16:53.65815	1CA248AE-2252-4F35-9C7B-310490274514
351	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	931	69	1000	0.003018	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 4: What change of state happens when clothes dry?"}	2025-10-13 18:17:19.307749	1CA248AE-2252-4F35-9C7B-310490274514
352	82c463e3-8349-4657-96a1-99ef136c9163	chat_response	gpt-4.1-mini	234	90	324	0.001485	\N	\N	{"gradeLevel": "4th grade", "messageCount": 1}	2025-10-13 18:19:44.448252	1CA248AE-2252-4F35-9C7B-310490274514
353	82c463e3-8349-4657-96a1-99ef136c9163	chat_response	gpt-4.1-mini	234	79	313	0.001375	\N	\N	{"gradeLevel": "4th grade", "messageCount": 1}	2025-10-13 18:19:46.822122	1CA248AE-2252-4F35-9C7B-310490274514
354	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	973	75	1048	0.003183	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 4: What change of state happens when clothes dry?"}	2025-10-13 18:20:06.536159	1CA248AE-2252-4F35-9C7B-310490274514
355	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	985	59	1044	0.003053	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 5: What change of state happens during the creation of clouds?"}	2025-10-13 18:20:22.022299	1CA248AE-2252-4F35-9C7B-310490274514
356	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4.1-mini	1023	55	1078	0.003108	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 6: What change of state happens when steel is fused?"}	2025-10-13 18:20:48.885935	1CA248AE-2252-4F35-9C7B-310490274514
357	25fa3bf5-4846-436b-afc8-8f95213a56a6	validate_image	gpt-4.1-mini	1064	95	1159	0.003610	\N	\N	{"fileSize": 39874, "mimeType": "image/jpeg"}	2025-10-13 22:04:05.269428	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
358	25fa3bf5-4846-436b-afc8-8f95213a56a6	analyze_homework	gpt-4.1-mini	2661	111	2772	0.007763	\N	\N	{"gradeLevel": "5th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 22:04:08.234151	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
359	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4.1-mini	796	53	849	0.002520	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What is the height of the cup?"}	2025-10-13 22:04:10.259778	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
360	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4.1-mini	838	86	924	0.002955	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What is the height of the cup?"}	2025-10-13 22:04:44.054243	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
361	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4.1-mini	838	91	929	0.003005	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What is the height of the cup?"}	2025-10-13 22:04:47.557497	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
362	25fa3bf5-4846-436b-afc8-8f95213a56a6	validate_image	gpt-4.1-mini	2561	30	2591	0.006703	\N	\N	{"fileSize": 124361, "mimeType": "image/jpeg"}	2025-10-13 22:54:52.896996	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
363	25fa3bf5-4846-436b-afc8-8f95213a56a6	analyze_homework	gpt-4o-mini	4158	527	4685	0.000940	\N	\N	{"gradeLevel": "5th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 22:55:02.696428	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
364	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	798	88	886	0.000173	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What is the height of one cup?"}	2025-10-13 22:55:05.168722	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
365	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	948	96	1044	0.000200	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: How do we use the total height of 5 stacked cups to find the height of one cup?"}	2025-10-13 22:56:51.47453	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
366	25fa3bf5-4846-436b-afc8-8f95213a56a6	validate_image	gpt-4o-mini	37149	106	37255	0.005636	\N	\N	{"fileSize": 162200, "mimeType": "image/jpeg"}	2025-10-13 23:29:22.649207	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
367	25fa3bf5-4846-436b-afc8-8f95213a56a6	analyze_homework	gpt-4o-mini	3954	445	4399	0.000860	\N	\N	{"gradeLevel": "5th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 23:29:36.935234	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
368	25fa3bf5-4846-436b-afc8-8f95213a56a6	analyze_homework	gpt-4o-mini	3954	437	4391	0.000855	\N	\N	{"gradeLevel": "5th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 23:29:39.897425	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
369	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	784	49	833	0.000147	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: Solve 7 × 100 = ___"}	2025-10-13 23:29:41.94008	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
370	25fa3bf5-4846-436b-afc8-8f95213a56a6	validate_image	gpt-4o-mini	37149	90	37239	0.005626	\N	\N	{"fileSize": 155834, "mimeType": "image/jpeg"}	2025-10-13 23:30:01.575136	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
371	25fa3bf5-4846-436b-afc8-8f95213a56a6	analyze_homework	gpt-4o-mini	3954	451	4405	0.000864	\N	\N	{"gradeLevel": "5th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 23:30:11.783039	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
372	25fa3bf5-4846-436b-afc8-8f95213a56a6	analyze_homework	gpt-4o-mini	3954	454	4408	0.000866	\N	\N	{"gradeLevel": "5th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 23:30:12.792931	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
373	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	794	69	863	0.000161	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: Solve 7 × 100 = ___"}	2025-10-13 23:30:13.440719	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
374	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	857	93	950	0.000184	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 2: Find the missing number in ___ × 60 = 6,000"}	2025-10-13 23:30:34.408386	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
375	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	901	93	994	0.000191	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 3: Calculate 800 × 5 = ___"}	2025-10-13 23:31:41.545271	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
376	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	977	81	1058	0.000195	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 3: Calculate 800 × 5 = ___"}	2025-10-13 23:32:15.328261	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
377	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	943	122	1065	0.000215	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 3: Calculate 800 × 5 = ___"}	2025-10-13 23:36:26.745507	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
378	25fa3bf5-4846-436b-afc8-8f95213a56a6	validate_image	gpt-4o-mini	48483	30	48513	0.007290	\N	\N	{"fileSize": 282264, "mimeType": "image/jpeg"}	2025-10-13 23:46:53.090038	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
379	25fa3bf5-4846-436b-afc8-8f95213a56a6	analyze_homework	gpt-4o-mini	4313	517	4830	0.000957	\N	\N	{"gradeLevel": "5th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-13 23:47:00.816344	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
380	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	791	45	836	0.000146	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: Ice cream in the summer."}	2025-10-13 23:47:05.980164	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
381	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	823	60	883	0.000159	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 2: Water boiling."}	2025-10-13 23:47:21.36326	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
382	25fa3bf5-4846-436b-afc8-8f95213a56a6	validate_image	gpt-4o-mini	8814	30	8844	0.001340	\N	\N	{"fileSize": 49604, "mimeType": "image/jpeg"}	2025-10-14 01:58:03.722017	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
383	25fa3bf5-4846-436b-afc8-8f95213a56a6	analyze_homework	gpt-4o-mini	2204	1473	3677	0.001214	\N	\N	{"gradeLevel": "5th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-14 01:58:22.521455	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
384	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	813	58	871	0.000157	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: Rewrite the run-on sentence as two separate sentences"}	2025-10-14 01:58:24.711986	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
385	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	889	77	966	0.000180	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: Rewrite the run-on sentence as two separate sentences"}	2025-10-14 01:58:50.608767	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
386	25fa3bf5-4846-436b-afc8-8f95213a56a6	validate_image	gpt-4o-mini	37149	30	37179	0.005590	\N	\N	{"fileSize": 92078, "mimeType": "image/jpeg"}	2025-10-14 02:51:11.3361	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
387	25fa3bf5-4846-436b-afc8-8f95213a56a6	analyze_homework	gpt-4o-mini	3531	665	4196	0.000929	\N	\N	{"gradeLevel": "5th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-14 02:51:22.137746	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
388	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	809	52	861	0.000153	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What state do you live in? Can you circle it on the map?"}	2025-10-14 02:51:23.624083	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
389	25fa3bf5-4846-436b-afc8-8f95213a56a6	generate_hint	gpt-4o-mini	885	75	960	0.000178	\N	\N	{"gradeLevel": "5th grade", "stepQuestion": "Problem 1: What state do you live in? Can you circle it on the map?"}	2025-10-14 02:51:38.43778	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86
390	82c463e3-8349-4657-96a1-99ef136c9163	validate_image	gpt-4o-mini	48483	30	48513	0.007290	\N	\N	{"fileSize": 1044994, "mimeType": "image/jpeg"}	2025-10-14 04:22:53.130772	1CA248AE-2252-4F35-9C7B-310490274514
391	82c463e3-8349-4657-96a1-99ef136c9163	analyze_homework	gpt-4o-mini	4221	570	4791	0.000975	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-14 04:23:03.700795	1CA248AE-2252-4F35-9C7B-310490274514
392	82c463e3-8349-4657-96a1-99ef136c9163	generate_hint	gpt-4o-mini	805	80	885	0.000169	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: Multiply 251 by 3 using partial products"}	2025-10-14 04:23:06.240937	1CA248AE-2252-4F35-9C7B-310490274514
393	8511b345-0d92-4c84-95a2-9d3483c8829e	validate_image	gpt-4o-mini	48483	71	48554	0.007315	\N	\N	{"fileSize": 1332360, "mimeType": "image/jpeg"}	2025-10-14 21:26:58.360698	FDA2BCA6-6C1A-4681-99BC-450713EDC958
394	8511b345-0d92-4c84-95a2-9d3483c8829e	analyze_homework	gpt-4o-mini	4398	1096	5494	0.001317	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-14 21:27:17.682687	FDA2BCA6-6C1A-4681-99BC-450713EDC958
395	8511b345-0d92-4c84-95a2-9d3483c8829e	generate_hint	gpt-4o-mini	781	46	827	0.000145	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is 4 + 3?"}	2025-10-14 21:27:19.634673	FDA2BCA6-6C1A-4681-99BC-450713EDC958
396	8511b345-0d92-4c84-95a2-9d3483c8829e	analyze_homework	gpt-4o-mini	4398	1066	5464	0.001299	\N	\N	{"gradeLevel": "4th grade", "problemText": null, "hasTeacherMethod": false}	2025-10-14 21:27:23.029689	FDA2BCA6-6C1A-4681-99BC-450713EDC958
397	8511b345-0d92-4c84-95a2-9d3483c8829e	generate_hint	gpt-4o-mini	853	48	901	0.000157	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is 4 + 3?"}	2025-10-14 21:28:13.142264	FDA2BCA6-6C1A-4681-99BC-450713EDC958
398	8511b345-0d92-4c84-95a2-9d3483c8829e	generate_hint	gpt-4o-mini	853	47	900	0.000156	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 1: What is 4 + 3?"}	2025-10-14 21:28:29.632952	FDA2BCA6-6C1A-4681-99BC-450713EDC958
399	8511b345-0d92-4c84-95a2-9d3483c8829e	generate_hint	gpt-4o-mini	827	58	885	0.000159	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: What is 8 + 2?"}	2025-10-14 21:28:45.045837	FDA2BCA6-6C1A-4681-99BC-450713EDC958
400	8511b345-0d92-4c84-95a2-9d3483c8829e	generate_hint	gpt-4o-mini	869	67	936	0.000171	\N	\N	{"gradeLevel": "4th grade", "stepQuestion": "Problem 2: What is 8 + 2?"}	2025-10-14 21:28:51.238022	FDA2BCA6-6C1A-4681-99BC-450713EDC958
\.


--
-- Data for Name: user_devices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_devices (user_id, device_id, device_name, is_trusted, first_seen, last_seen, login_count) FROM stdin;
ba57e63c-23bb-44d0-99a7-052c309b5b2b	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-15 02:58:18.442311	2025-10-15 02:58:18.442311	1
515a3b0b-5105-445b-aaa0-06c9432a01a7	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-15 02:59:36.226216	2025-10-15 02:59:36.226216	1
b1cfd676-d3dd-4979-9bef-7d79e7c36297	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-15 03:05:51.453636	2025-10-15 03:05:51.453636	1
515a3b0b-5105-445b-aaa0-06c9432a01a7	2A4BDB43-B4BB-46BD-9368-2E205BD95D08	iPhone	f	2025-10-15 22:13:49.715847	2025-10-15 22:13:49.715847	1
a55de8e9-ebb9-4fad-bd2d-4596f4a520cf	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-11 20:22:27.204824	2025-10-12 21:13:03.737499	11
d4050ff7-da76-4a37-a1f6-585bbeda199d	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-12 01:25:42.48248	2025-10-12 21:34:21.728791	5
33bc2695-7dcf-4109-bb70-ffc6fcb958a8	test-device	Test iPhone	f	2025-10-09 21:27:51.761788	2025-10-09 21:27:51.761788	1
f430a463-c285-4ab3-a8d5-7fd38f0c5f85	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-12 21:44:41.727768	2025-10-12 21:44:41.727768	1
610b14cb-c446-46b7-bcac-e0565e7ea5ea	test-device-123	Test iPhone	f	2025-10-09 21:28:03.203615	2025-10-09 21:28:03.203615	1
8cbe43e9-be23-4c9a-8b0f-de13f05432b9	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-11 20:23:06.797317	2025-10-12 21:48:49.80738	7
8ca1bd33-89e6-4508-92df-872fc8450ef4	unknown	Unknown Device	f	2025-10-09 21:28:57.623161	2025-10-09 21:28:57.623161	1
3797d874-5599-4844-8d6d-e1958e11d82a	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	iPhone	f	2025-10-09 21:02:47.784029	2025-10-09 22:34:59.045263	8
fc06e3c3-d68e-42aa-b584-b0a59ae8c718	unknown	Unknown Device	f	2025-10-10 17:35:11.05238	2025-10-10 17:35:11.05238	1
81ec2385-7f7f-4db8-89b9-204d0c24a1df	unknown	Unknown Device	f	2025-10-10 17:15:26.515462	2025-10-10 17:52:42.940344	2
f30fe78c-277e-432e-a1f6-83c4fad36837	16B4EB1B-D2BA-4E7A-A40F-CF01B1C6AE1C	iPhone	f	2025-10-09 21:02:08.797217	2025-10-10 17:56:03.956936	12
f30fe78c-277e-432e-a1f6-83c4fad36837	unknown	Unknown Device	f	2025-10-10 19:12:25.293608	2025-10-10 19:12:25.293608	1
3797d874-5599-4844-8d6d-e1958e11d82a	5C075B04-25B8-4915-A49A-0E1EF0E5C6B3	iPhone	f	2025-10-11 00:12:45.47581	2025-10-11 00:12:45.47581	1
f30fe78c-277e-432e-a1f6-83c4fad36837	5C075B04-25B8-4915-A49A-0E1EF0E5C6B3	iPhone	f	2025-10-10 23:38:35.595732	2025-10-11 00:48:36.276807	2
3797d874-5599-4844-8d6d-e1958e11d82a	AC10B57F-4137-4F20-9C76-A7C9540F387E	iPhone	f	2025-10-11 03:32:05.436178	2025-10-11 03:32:05.436178	1
f30fe78c-277e-432e-a1f6-83c4fad36837	7475847D-E5AC-4675-84BC-28BECB336E35	iPhone	f	2025-10-11 04:09:19.843967	2025-10-11 04:09:19.843967	1
3797d874-5599-4844-8d6d-e1958e11d82a	1EC2C674-60A2-42C5-8D8E-760561CFDD32	iPhone	f	2025-10-11 04:13:05.014639	2025-10-11 04:13:05.014639	1
3797d874-5599-4844-8d6d-e1958e11d82a	196A465D-D76E-4029-8835-4CCCCCD38612	iPhone	f	2025-10-11 17:42:59.540143	2025-10-11 17:42:59.540143	1
f30fe78c-277e-432e-a1f6-83c4fad36837	F877F805-6C36-4648-8024-A739638B1DFE	iPhone	f	2025-10-11 04:24:21.735838	2025-10-11 19:21:54.570435	2
82c463e3-8349-4657-96a1-99ef136c9163	1CA248AE-2252-4F35-9C7B-310490274514	iPhone	f	2025-10-14 04:25:04.790596	2025-10-14 04:25:04.790596	1
c21dc002-5828-4cd6-b414-4ef55a6d8e31	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-12 23:55:48.308435	2025-10-14 04:28:45.865269	5
71cc27f6-5272-435c-a326-5853af953e77	7128365C-CB0B-4430-9333-6AA2CD7F5C1A	iPad	f	2025-10-14 17:47:21.730176	2025-10-14 17:47:21.730176	1
8cbe43e9-be23-4c9a-8b0f-de13f05432b9	196A465D-D76E-4029-8835-4CCCCCD38612	iPhone	f	2025-10-11 23:46:53.727892	2025-10-11 23:46:53.727892	1
db27c446-cab9-40dc-b5a3-1b9863c8437f	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-11 21:56:41.195877	2025-10-12 01:23:22.04193	2
8511b345-0d92-4c84-95a2-9d3483c8829e	FDA2BCA6-6C1A-4681-99BC-450713EDC958	iPhone	f	2025-10-14 21:25:09.934008	2025-10-14 21:25:09.934008	1
4fb71701-c436-49ab-950b-6b32b0141897	unknown	Unknown Device	f	2025-10-15 00:10:50.625484	2025-10-15 00:10:50.625484	1
25fa3bf5-4846-436b-afc8-8f95213a56a6	2CACD9BD-47E4-4F81-8DFA-4E481AA74E86	iPhone	f	2025-10-12 22:00:16.199105	2025-10-15 01:11:25.664196	4
\.


--
-- Data for Name: user_entitlements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_entitlements (id, user_id, product_id, subscription_group_id, original_transaction_id, original_transaction_id_hash, is_trial, status, purchase_at, expires_at, created_at, updated_at) FROM stdin;
\.


--
-- Name: admin_users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.admin_users_id_seq', 1, true);


--
-- Name: device_logins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.device_logins_id_seq', 92, true);


--
-- Name: fraud_flags_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.fraud_flags_id_seq', 54, true);


--
-- Name: password_reset_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.password_reset_tokens_id_seq', 19, true);


--
-- Name: promo_code_usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.promo_code_usage_id_seq', 1, false);


--
-- Name: promo_codes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.promo_codes_id_seq', 3, true);


--
-- Name: subscription_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subscription_history_id_seq', 81, true);


--
-- Name: trial_usage_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.trial_usage_history_id_seq', 1, false);


--
-- Name: user_api_usage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_api_usage_id_seq', 400, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 56, true);


--
-- PostgreSQL database dump complete
--

\unrestrict afqVzj8iWZaMSDezIpVxAG1LKMjm3iSIBGI2ZJjBZRb0YbLAhfEA0mtBdRkUWZw

