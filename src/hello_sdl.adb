with SDL;
with SDL.Timers;
with SDL.Video.Pixel_Formats;
with SDL.Video.Surfaces;
with SDL.Video.Palettes;
with SDL.Video.Windows;
with SDL.Video.Windows.Makers;

procedure Hello_SDL is

   Label    : constant String                  := "Hello SDL";
   Position : constant SDL.Natural_Coordinates :=
     (SDL.Video.Windows.Undefined_Window_Position (0), 100);
   Width  : constant := 400;
   Height : constant := 300;

begin
   if not SDL.Initialise then
      raise Program_Error;
   end if;

   declare
      W : SDL.Video.Windows.Window;
      S : SDL.Video.Surfaces.Surface;
   begin
      SDL.Video.Windows.Makers.Create (W, Label, Position, (Width, Height));
      S := W.Get_Surface;
      for I in 1 .. 255 loop
         declare
            R : constant SDL.Video.Palettes.Colour_Component :=
              SDL.Video.Palettes.Colour_Component (I);
            G : constant SDL.Video.Palettes.Colour_Component :=
              SDL.Video.Palettes.Colour_Component (255 - I);
            B : constant SDL.Video.Palettes.Colour_Component :=
              SDL.Video.Palettes.Colour_Component (128 + (I / 2));
         begin
            S.Fill
              (Area   => (0, 0, Width, Height),
               Colour =>
                 SDL.Video.Pixel_Formats.To_Pixel (S.Pixel_Format, R, G, B));
            W.Update_Surface;
            SDL.Timers.Wait_Delay (10);
         end;
      end loop;
   end;

   SDL.Finalise;
end Hello_SDL;
