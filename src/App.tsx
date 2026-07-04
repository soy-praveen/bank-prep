import { Route, Routes } from 'react-router-dom';
import Shell from './components/Shell';
import Dashboard from './pages/Dashboard';
import Mocks from './pages/Mocks';
import Practice from './pages/Practice';
import Syllabus from './pages/Syllabus';
import Tricks from './pages/Tricks';
import Pomodoro from './pages/Pomodoro';
import Settings from './pages/Settings';
import TestPlayer from './pages/TestPlayer';
import Results from './pages/Results';

export default function App() {
  return (
    <Routes>
      {/* the exam player runs fullscreen, outside the shell */}
      <Route path="/test" element={<TestPlayer />} />
      <Route element={<Shell />}>
        <Route path="/" element={<Dashboard />} />
        <Route path="/mocks" element={<Mocks />} />
        <Route path="/practice" element={<Practice />} />
        <Route path="/syllabus" element={<Syllabus />} />
        <Route path="/tricks" element={<Tricks />} />
        <Route path="/pomodoro" element={<Pomodoro />} />
        <Route path="/settings" element={<Settings />} />
        <Route path="/results/:rid" element={<Results />} />
      </Route>
    </Routes>
  );
}
