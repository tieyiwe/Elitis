/* Elitis Express · Menu à bord : configuration en ligne
   Collez ici l'URL du projet Supabase et sa clé « anon / publishable »
   (Supabase > Project Settings > API). Cette clé est faite pour être publique :
   la sécurité est assurée par les règles de la base (voir supabase.sql) et le PIN hôtesse.
   Laissez vide pour fonctionner hors ligne. */
window.ELT_CONFIG = Object.assign({
  url: "",   // ex. "https://abcdefgh.supabase.co"
  key: ""    // ex. "eyJhbGciOi..." ou "sb_publishable_..."
}, window.ELT_CONFIG || {});
