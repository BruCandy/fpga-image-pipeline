import { Button } from "@chakra-ui/react"


type PropType = {
    sendState: number;
    onSelect: (src: string) => void;
}

export default function ResetButton({ sendState, onSelect }: PropType) {
    const handleButton = () => {
        onSelect("");
    }
    return (
        <Button
            disabled={sendState==0 ? false : true}
            onClick={handleButton}
            bg={sendState==0 ? "white" : "#666666ff"} 
            width="100px"
        >
            リセット
        </Button>
    );
}
