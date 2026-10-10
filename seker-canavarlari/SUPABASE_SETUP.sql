-- ==========================================
-- ŞEKER CANAVARLARI - SUPABASE KURULUMU
-- ==========================================
-- Supabase Dashboard > SQL Editor sekmesine gidip
-- aşağıdaki kodları yapıştırarak "Run" diyebilirsiniz.

-- 1. PROFİLLER TABLOSU (Liderlik Tablosu & Oyuncu Bilgileri)
CREATE TABLE IF NOT EXISTS public.profiles (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  nickname TEXT NOT NULL DEFAULT 'Şekersever',
  stars INTEGER NOT NULL DEFAULT 0,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 2. KAYITLAR TABLOSU (Oyunun Bulut Kayıt Verisi / JSON)
CREATE TABLE IF NOT EXISTS public.saves (
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  data JSONB NOT NULL DEFAULT '{}'::jsonb,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- 3. ROW LEVEL SECURITY (RLS - Güvenlik Politikaları)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saves ENABLE ROW LEVEL SECURITY;

-- Profiles: Herkes sıralamayı görebilir (SELECT)
DROP POLICY IF EXISTS "Profiles public read" ON public.profiles;
CREATE POLICY "Profiles public read" 
  ON public.profiles FOR SELECT 
  USING (true);

-- Profiles: Kullanıcı kendi profilini ekleyebilir (INSERT)
DROP POLICY IF EXISTS "Profiles user insert" ON public.profiles;
CREATE POLICY "Profiles user insert" 
  ON public.profiles FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Profiles: Kullanıcı kendi profilini güncelleyebilir (UPDATE)
DROP POLICY IF EXISTS "Profiles user update" ON public.profiles;
CREATE POLICY "Profiles user update" 
  ON public.profiles FOR UPDATE 
  USING (auth.uid() = user_id);

-- Saves: Kullanıcı yalnızca kendi bulut kaydını okuyabilir (SELECT)
DROP POLICY IF EXISTS "Saves user select" ON public.saves;
CREATE POLICY "Saves user select" 
  ON public.saves FOR SELECT 
  USING (auth.uid() = user_id);

-- Saves: Kullanıcı kendi kaydını ekleyebilir (INSERT)
DROP POLICY IF EXISTS "Saves user insert" ON public.saves;
CREATE POLICY "Saves user insert" 
  ON public.saves FOR INSERT 
  WITH CHECK (auth.uid() = user_id);

-- Saves: Kullanıcı kendi kaydını güncelleyebilir (UPDATE)
DROP POLICY IF EXISTS "Saves user update" ON public.saves;
CREATE POLICY "Saves user update" 
  ON public.saves FOR UPDATE 
  USING (auth.uid() = user_id);

-- ========================================================
-- ÖNEMLİ TAVSİYE (Oyuncuların Anında Giriş Yapabilmesi İçin):
-- Supabase Dashboard > Authentication > Providers > Email
-- bölümüne gidip "Confirm email" seçeneğini KAPATIN (Uncheck).
-- Böylece oyuncular e-posta onayı beklemeden anında kayıt olup oynayabilir.
-- ========================================================
