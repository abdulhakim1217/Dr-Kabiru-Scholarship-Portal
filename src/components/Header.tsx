import { Button } from "@/components/ui/button";
import { useTheme } from "@/contexts/ThemeContext";
import { Sun, Moon } from "lucide-react";

const Header = () => {
  const { theme, toggleTheme } = useTheme();
  const scrollToSection = (id: string) => {
    document.getElementById(id)?.scrollIntoView({ behavior: "smooth" });
  };

  return (
    <header className="fixed top-0 left-0 right-0 z-50 bg-background border-b-2 border-border">
      <div className="container mx-auto px-4 py-4 flex items-center justify-between">
        <div className="font-bold text-xl tracking-tight">
          DR. KABIRU MP<span className="text-muted-foreground ml-2">SCHOLARSHIP</span>
        </div>
        <nav className="hidden md:flex items-center gap-8">
          <button 
            onClick={() => scrollToSection("about")}
            className="text-sm font-medium hover:underline underline-offset-4"
          >
            About
          </button>
          <button 
            onClick={() => scrollToSection("eligibility")}
            className="text-sm font-medium hover:underline underline-offset-4"
          >
            Eligibility
          </button>
          <button 
            onClick={() => scrollToSection("apply")}
            className="text-sm font-medium hover:underline underline-offset-4"
          >
            Apply
          </button>
        </nav>
        <div className="flex items-center gap-4">
          <Button
            variant="ghost"
            size="icon"
            onClick={toggleTheme}
            aria-label="Toggle theme"
            className="hover:bg-secondary"
          >
            {theme === 'light' ? (
              <Moon className="h-5 w-5" />
            ) : (
              <Sun className="h-5 w-5" />
            )}
          </Button>
          <Button 
            onClick={() => scrollToSection("apply")}
            className="shadow-sm hover:shadow-md transition-shadow"
          >
            Apply Now
          </Button>
        </div>
      </div>
    </header>
  );
};

export default Header;
