/* Alikuryer Supabase catalog adapter — read only, V11 design unchanged.
   Public publishable key only. Never use service_role in the browser.
   RLS must restrict public SELECT to active restaurants and available menu items.
*/
export function createCatalog(supabase) {
  if (!supabase) throw new Error("Supabase client is required");
  return {
    async restaurants() {
      const { data, error } = await supabase.from("restaurants")
        .select("id,name,description,address_line,latitude,longitude")
        .eq("is_active", true).order("name");
      if (error) throw error;
      return data ?? [];
    },
    async categories() {
      const { data, error } = await supabase.from("categories")
        .select("id,name,sort_order").order("sort_order");
      if (error) throw error;
      return data ?? [];
    },
    async menuItems(restaurantId) {
      if (!restaurantId) throw new Error("Restaurant ID is required");
      const { data, error } = await supabase.from("menu_items")
        .select("id,restaurant_id,category_id,name,description,price_uzs,image_path")
        .eq("restaurant_id", restaurantId)
        .eq("is_available", true).order("name");
      if (error) throw error;
      return data ?? [];
    },
    async myOrders() {
      const { data: auth, error: authError } = await supabase.auth.getUser();
      if (authError) throw authError;
      if (!auth.user) throw new Error("Tizimga kirish talab qilinadi");
      const { data, error } = await supabase.from("orders")
        .select("id,restaurant_id,delivery_address,status,subtotal_uzs,delivery_fee_uzs,total_uzs,created_at")
        .eq("customer_id", auth.user.id)
        .order("created_at", { ascending: false });
      if (error) throw error;
      return data ?? [];
    }
  };
}
