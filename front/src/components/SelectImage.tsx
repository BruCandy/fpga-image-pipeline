import imgA from "../assets/rabbit1.png";
import imgB from "../assets/rabbit2.png";
import imgC from "../assets/rabbit3.png";
import { Card, CardBody, CardHeader, VStack, Wrap, WrapItem} from "@chakra-ui/react";


type PropType = {
    Image: string;
    onSelect: (src: string) => void;
}

const images = [imgA, imgB, imgC];


export default function ImageSelector({ Image, onSelect }: PropType) {

  return (
    <VStack>
        <Wrap spacing="10px">
            {images.map((src) => (
                <WrapItem key={src}>
                    <Card 
                        className='mb-8 flex w-full scroll-mt-20 flex-col shadow-md'
                        onClick={() => onSelect(src)}
                        style={{cursor: "pointer", backgroundColor: Image == src ? "#e2e8f0" : "white" }}
                    >
                        <CardBody>
                            <img
                                src={src}
                                style={{ width: "45px"}}
                            />
                        </CardBody>
                    </Card>
                </WrapItem>
            ))}
        </Wrap>

        <div>
            {Image ? 
                <Card 
                    className='mb-8 flex w-full scroll-mt-20 flex-col shadow-md'
                    w="500px"
                    h="500px"
                >
                    <CardHeader>選択された画像</CardHeader>
                    <CardBody><img src={Image} style={{ width: "400px"}}/></CardBody>
                </Card>
                : 
                <Card 
                    className='mb-8 flex w-full scroll-mt-20 flex-col shadow-md'
                    w="500px"
                    h="500px"
                    bg={"gray.100"}
                >
                    <CardBody
                        display="flex"
                        alignItems="center"
                        justifyContent="center"
                    >
                        <p className="text-4xl font-bold text-gray-400">No Data</p>
                    </CardBody>
                </Card>
            }
      </div>
    </VStack>
  );
}
